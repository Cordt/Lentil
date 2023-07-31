// Lentil
// Created by Laura and Cordt Zermin

import Combine
import Foundation
import Starscream
import WalletConnectModal
import WalletConnectRelay
import web3


fileprivate class WalletEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case didEstablishSession(Session)
    case didDisconnect
    case receivedResponse(Response)
  }
  
  typealias Element = Event
  var eventsToEmit: [Event] = []
  
  func next() async throws -> Element? {
    while true {
      try await Task.sleep(nanoseconds: NSEC_PER_SEC / 4)
      if !self.eventsToEmit.isEmpty {
        return self.eventsToEmit.removeFirst()
      }
    }
  }
  
  func makeAsyncIterator() -> WalletEvents {
    self
  }
}


class WalletConnector {
  static let shared: WalletConnector = WalletConnector()
  private var publishers = Set<AnyCancellable>()
  private let walletEvents = WalletEvents()
  private let metadata = AppMetadata(
    name: "Lentil",
    description: "Lentil - the Lens iOS App",
    url: "http://lentilapp.xyz",
    icons: [LentilEnvironment.shared.lentilIconIPFSUrl]
  )
  private let polygonNamespace = ProposalNamespace(
    chains: [
      Blockchain("eip155:137")!
    ],
    methods: [
      "eth_sendTransaction",
      "personal_sign",
      "eth_signTypedData"
    ], events: []
  )
  
  private func setupSinks() {
    Sign.instance.sessionsPublisher
      .receive(on: DispatchQueue.main)
      .sink {  _ in
      }
      .store(in: &publishers)
    
    Sign.instance.sessionSettlePublisher
      .receive(on: DispatchQueue.main)
      .sink { session in
        self.walletEvents
          .eventsToEmit
          .append(.didEstablishSession(session))
      }
      .store(in: &publishers)
    
    Sign.instance.sessionDeletePublisher
      .receive(on: DispatchQueue.main)
      .sink {  _ in
      }
      .store(in: &publishers)
    
    Sign.instance.sessionResponsePublisher
      .receive(on: DispatchQueue.main)
      .sink { response in
        self.walletEvents
          .eventsToEmit
          .append(.receivedResponse(response))
      }
      .store(in: &publishers)
  }
  
  private func listenForEvent() async throws -> WalletEvents.Event? {
    for try await emmitedEvent in self.walletEvents {
      return emmitedEvent
    }
    try await Task.sleep(until: .now + .seconds(15), clock: .continuous)
    return nil
  }
  
  private init() {
    let namespaces: [String: ProposalNamespace] = ["eip155": self.polygonNamespace]
    let optionalNamespaces: [String: ProposalNamespace] = [:]
    let sessionProperties: [String: String] = ["caip154-mandatory": "true"]
    
    Networking.configure(
      projectId: LentilEnvironment.shared.wcProjectId,
      socketFactory: DefaultSocketFactory(),
      socketConnectionType: .automatic
    )
    
    WalletConnectModal.configure(
      projectId: LentilEnvironment.shared.wcProjectId,
      metadata: metadata
    )
    
    Pair.configure(
      metadata: metadata
    )
    
    WalletConnectModal.set(
      sessionParams: .init(
        requiredNamespaces: namespaces,
        optionalNamespaces: optionalNamespaces,
        sessionProperties: sessionProperties
      )
    )
    
    self.setupSinks()
    
#if DEBUG
    try? Sign.instance.cleanup()
#endif
  }
  
  
  // MARK: - Public Interface
  
  enum CommunicationError: Error {
    case invalidWalletResponse
    case invalidWalletAddress
    case invalidSession
    case failedToSign
  }
  
  func connect() async throws -> String {
    Task { @MainActor in
      WalletConnectModal.present()
    }
    guard case .didEstablishSession(let session) = try await self.listenForEvent()
    else { throw CommunicationError.invalidWalletResponse }
    
    guard let address = session.accounts.first?.address
    else { throw CommunicationError.invalidWalletAddress }
    
    return address
  }
  
  func disconnect() throws {
    try Sign.instance.cleanup()
  }
  
  func personalSign(message: String) async throws -> String {
    guard let session = Sign.instance.getSessions().first,
          let address = session.accounts.first?.address
    else { throw CommunicationError.invalidSession }
    
    let namespaces: [String: ProposalNamespace] = ["eip155": polygonNamespace]
    let uri = try await Pair.instance.create()
    try await Sign.instance.connect(requiredNamespaces: namespaces, topic: uri.topic)
    
    let method = "personal_sign"
    let requestParams = AnyCodable([message, address])
    let request = Request(topic: session.topic, method: method, params: requestParams, chainId: Blockchain("eip155:137")!)
    
    Task { @MainActor in
      try await Sign.instance.request(params: request)
    }
    
    guard case .receivedResponse(let response) = try await self.listenForEvent()
    else { throw CommunicationError.invalidWalletResponse }
    
    guard let signature = try? response
      .result
      .asJSONEncodedString()
      .replacingOccurrences(of: "\"", with: "")
    else { throw CommunicationError.invalidWalletResponse }
    
    return signature
  }
  
  func personalSign(data: Data) async throws -> Data {
    guard let message = String(data: data, encoding: .utf8)
    else { throw CommunicationError.failedToSign }
    
    let signedMessage = try await self.personalSign(message: message)
    
    guard let resultDataBytes = signedMessage.web3.bytesFromHex
    else { throw CommunicationError.failedToSign }
    
    return Data(resultDataBytes)
  }
}
