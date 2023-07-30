// Lentil
// Created by Laura and Cordt Zermin

import Combine
import ComposableArchitecture
import Foundation
import WalletConnectRelay
import WalletConnectNetworking
import WalletConnectModal
import UIKit
import web3


enum WalletConnectorError: Error {
  case couldNotCreateKey
  case couldNotConnectClient
  case couldNotReconnectClient
  case couldNotSignMessage
}

extension WalletConnectorApi: DependencyKey {
  static var liveValue: WalletConnectorApi {
    WalletConnectorApi(
      eventStream: WalletConnector.shared.eventStream,
      connect: WalletConnector.shared.connect,
      disconnect: WalletConnector.shared.disconnect,
      signMessage: WalletConnector.shared.signMessage,
      signData: WalletConnector.shared.signData
    )
  }
}

extension DependencyValues {
  var walletConnect: WalletConnectorApi {
    get { self[WalletConnectorApi.self] }
    set { self[WalletConnectorApi.self] = newValue }
  }
}

struct WalletConnectorApi {
  var eventStream: WalletEvents
  var connect: () -> Void
  var disconnect: () -> Void
  var signMessage: (_ message: String) async throws -> Void
  var signData: (_ data: Data) async throws -> Void
}

class WalletConnector {
  static let shared: WalletConnector = WalletConnector()
  private var publishers = Set<AnyCancellable>()
  private let walletEvents = WalletEvents()
  private let polygonNamespace: ProposalNamespace
  
  var session: Session?
  var address: String {
    // FIXME: Requirement of SigningKey Protocol of XMTP - shouldn't be made available like this
    guard let account = self.session?.accounts.first?.address
    else { return "" }
    
    return EthereumAddress(account).toChecksumAddress()
  }
  var eventStream: WalletEvents { self.walletEvents }
  
  private init() {
    let metadata = AppMetadata(
      name: "Lentil",
      description: "Lentil - the Lens iOS App",
      url: "http://lentilapp.xyz",
      icons: [LentilEnvironment.shared.lentilIconIPFSUrl]
    )
    
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
    
    self.polygonNamespace = ProposalNamespace(
      chains: [
        Blockchain("eip155:137")!
      ],
      methods: [
        "eth_sendTransaction",
        "personal_sign",
        "eth_signTypedData"
      ], events: []
    )
    let namespaces: [String: ProposalNamespace] = ["eip155": polygonNamespace]
    let optionalNamespaces: [String: ProposalNamespace] = [:]
    let sessionProperties: [String: String] = ["caip154-mandatory": "true"]
    
    WalletConnectModal.set(
      sessionParams: .init(
        requiredNamespaces: namespaces,
        optionalNamespaces: optionalNamespaces,
        sessionProperties: sessionProperties
      ))
    
    #if DEBUG
    try? Sign.instance.cleanup()
    #endif
    
    if let session = Sign.instance.getSessions().first {
      self.eventStream.eventsToEmit.append(.didEstablishSession(session))
    }
    
    Sign.instance.sessionsPublisher
      .receive(on: DispatchQueue.main)
      .sink { sessions in
      }.store(in: &publishers)
    
    
    Sign.instance.sessionDeletePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        self.session = nil
        self.eventStream.eventsToEmit.append(.didDisconnect)
      }.store(in: &publishers)
    
    Sign.instance.sessionResponsePublisher
      .receive(on: DispatchQueue.main)
      .sink { response in
        guard let signature = try? response
          .result
          .asJSONEncodedString()
          .replacingOccurrences(of: "\"", with: "")
        else {
          log("Unable to parse response from wallet", level: .debug)
          return
        }
        self.eventStream.eventsToEmit.append(.receivedResponse(signature))
      }.store(in: &publishers)
    
    Sign.instance.sessionSettlePublisher
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] session in
        self.session = session
        self.eventStream.eventsToEmit.append(.didEstablishSession(session))
      }.store(in: &publishers)
  }
  
  func connect() {
    WalletConnectModal.present()
  }
  
  func disconnect() {
    do {
      try Pair.instance.cleanup()
    } catch let error {
      log("Could not disconnect from WC", level: .warn, error: error)
    }
  }
  
  func signMessage(message: String) async throws {
    guard let topic = self.session?.topic,
          let address = self.session?.accounts.first?.address
    else { throw WalletConnectorError.couldNotSignMessage }
    
    let namespaces: [String: ProposalNamespace] = ["eip155": self.polygonNamespace]
    let uri = try await Pair.instance.create()
    try await Sign.instance.connect(requiredNamespaces: namespaces, topic: uri.topic)
    
    let method = "personal_sign"
    let requestParams = AnyCodable([message, address])
    let request = Request(topic: topic, method: method, params: requestParams, chainId: Blockchain("eip155:137")!)
        
    try await Sign.instance.request(params: request)
  }
  
  func signData(_ data: Data) async throws {
    guard let message = String(data: data, encoding: .utf8)
    else { throw WalletConnectorError.couldNotSignMessage }

    try await self.signMessage(message: message)
  }
}


class WalletEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case didEstablishSession(Session)
    case didDisconnect
    case receivedResponse(String)
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
