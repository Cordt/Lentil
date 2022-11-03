// Lentil

import Combine
import ComposableArchitecture
import CoreImage.CIFilterBuiltins
import Foundation
import Starscream
import WalletConnectSign
import WalletConnectPairing
import WalletConnectNetworking
import WalletConnectRelay
import UIKit

extension WebSocket: WebSocketConnecting { }
struct SocketFactory: WebSocketFactory {
  func create(with url: URL) -> WebSocketConnecting {
    return WebSocket(url: url)
  }
}


struct QRCodeGenerator {
  static func generateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")
    let transform = CGAffineTransform(scaleX: 4, y: 4)
    if let qrCodeImage = filter.outputImage?.transformed(by: transform) {
      if let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
        return UIImage(cgImage: qrCodeCGImage)
      }
    }
    
    return UIImage()
  }
}


enum Chain: CaseIterable {
  case ethereum, polygon
  
  var name: String {
    switch self {
      case .ethereum: return "Ethereum"
      case .polygon: return "Polygon"
    }
  }
  var id: String {
    switch self {
      case .ethereum: return "eip155:1"
      case .polygon: return "eip155:137"
    }
  }
  var blockchain: Blockchain? { Blockchain(self.id) }
}

enum WalletMethod: CaseIterable {
  case transaction, signature, typedData
  
  var method: String {
    switch self {
      case .transaction: return "eth_sendTransaction"
      case .signature: return "personal_sign"
      case .typedData: return "eth_signTypedData"
    }
  }
}

class WalletConnect {
  
  private var publishers = Set<AnyCancellable>()
  
  func connect() {
    let metadata = AppMetadata(
      name: "Lentil iOS",
      description: "A mobile Client for Lens Protocol that accesses the protocol through the users wallet",
      url: "https://cordt.zermin",
      icons: ["https://avatars.githubusercontent.com/u/37784886"]
    )
    
    Networking.configure(projectId: ProcessInfo.processInfo.environment["WALLETCONNECT_PROJECT_ID"]!, socketFactory: SocketFactory())
    Pair.configure(metadata: metadata)
  }
  
  func selectChain() async throws -> WalletConnectURI {
    print("[PROPOSER] Connecting to a pairing...")
    let blockchains = Chain.allCases
      .compactMap { $0.blockchain }
    
    let methods = WalletMethod.allCases
      .map { $0.method }
    
    let namespaces: [String: ProposalNamespace] = [
      "eip155": ProposalNamespace(chains: Set(blockchains), methods: Set(methods), events: [], extensions: nil)
    ]
    
    let uri = try await Pair.instance.create()
    try await Sign.instance.connect(requiredNamespaces: namespaces, topic: uri.topic)
    
    Sign.instance.sessionProposalPublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionProposalPublisher") }
      .store(in: &publishers)
    Sign.instance.sessionRequestPublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionRequestPublisher") }
      .store(in: &publishers)
    Sign.instance.socketConnectionStatusPublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received socketConnectionStatusPublisher") }
      .store(in: &publishers)
    Sign.instance.sessionSettlePublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionSettlePublisher") }
      .store(in: &publishers)
    Sign.instance.sessionDeletePublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionDeletePublisher") }
      .store(in: &publishers)
    Sign.instance.sessionResponsePublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionResponsePublisher") }
      .store(in: &publishers)
    Sign.instance.sessionRejectionPublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionRejectionPublisher") }
      .store(in: &publishers)
    Sign.instance.sessionUpdatePublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionUpdatePublisher") }
      .store(in: &publishers)
    Sign.instance.sessionEventPublisher.receive(on: DispatchQueue.main).sink { [unowned self] _ in print("Received sessionEventPublisher") }
      .store(in: &publishers)
    
    return uri
  }
  
  func openWallet(uri: WalletConnectURI) {
    let url = URL(string: "wc://wc?uri=\(uri.absoluteString)")!
    DispatchQueue.main.async {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}

extension WalletConnect: DependencyKey {
  static let liveValue = WalletConnect()
}

extension DependencyValues {
  var walletConnect: WalletConnect {
    get { self[WalletConnect.self] }
    set { self[WalletConnect.self] = newValue }
  }
}













///// Structure to store information about a crypto wallet
//struct CryptoWallet: Identifiable, Equatable {
//  /// Wallet address (e.g. 0x..... as string)
//  var address: String
//
//  /// Unique identifier (for Identifiable protocol)
//  var id: String { address }
//}
//
//
//class WalletConnectProxyFactory {
//  func failedToConnect(proxy: WalletConnectProxy) -> AsyncStream<Void> {
//    return AsyncStream { continuation in
//      proxy.failedToConnect = { continuation.yield() }
//    }
//  }
//
//  func didConnect(proxy: WalletConnectProxy) -> AsyncStream<Session.WalletInfo> {
//    return AsyncStream(Session.WalletInfo.self) { continuation in
//      proxy.didConnect = { continuation.yield($0) }
//    }
//  }
//
//  func didDisconnect(proxy: WalletConnectProxy) -> AsyncStream<Void> {
//    return AsyncStream { continuation in
//      proxy.didDisconnect = { continuation.yield() }
//    }
//  }
//}
//
//extension WalletConnectProxy: DependencyKey {
//  static let liveValue = WalletConnectProxy()
//}
//
//extension WalletConnectProxyFactory: DependencyKey {
//  static let liveValue = WalletConnectProxyFactory()
//}
//
//extension DependencyValues {
//  var walletConnectProxy: WalletConnectProxy {
//    get { self[WalletConnectProxy.self] }
//    set { self[WalletConnectProxy.self] = newValue }
//  }
//
//  var walletConnectFactory: WalletConnectProxyFactory {
//    get { self[WalletConnectProxyFactory.self] }
//    set { self[WalletConnectProxyFactory.self] = newValue }
//  }
//}
//
///// Main class to interface with the WalletConnect SwiftUI package
//class WalletConnectProxy: ClientDelegate {
//
//  var client: Client!
//  var session: Session!
//
//  var failedToConnect: (() -> ())?
//  var didConnect: ((_ wallet: Session.WalletInfo) -> ())?
//  var didDisconnect: (() -> ())?
//
//  /// Key to store session data in persistent application storage
//  let sessionKey = "sessionKey"
//
//  /// Main class constructor / initializer
//  init() { }
//
//  /// Set delegate
//  func subscribe(
//    failedToConnect: @escaping () -> (),
//    didConnect: @escaping (_ wallet: Session.WalletInfo) -> (),
//    didDisconnect: @escaping () -> ()
//  ) -> Void {
//    self.failedToConnect = failedToConnect
//    self.didConnect = didConnect
//    self.didDisconnect = didDisconnect
//  }
//
//  // MARK: - Connection functions
//
//  /// Open a websocket connection with the WalletConnect bridge server
//  func connect() -> String {
//    // Create a WalletConnect URL
//    let wcUrl =  WCURL(
//      topic: UUID().uuidString,
//      bridgeURL: URL(string: "https://bridge.walletconnect.org/")!,
//      key: try! generateRandomKey()
//    )
//
//    // Fill in the required information about this decentralized app
//    let clientMeta = Session.ClientMeta(
//      name: "Lentil iOS",
//      description: "A mobile Client for Lens Protocol that accesses the protocol through the users wallet",
//      icons: [],
//      url: URL(string: "https://lentil.xyz")!
//    )
//
//    let dAppInfo = Session.DAppInfo(
//      peerId: UUID().uuidString,
//      peerMeta: clientMeta
//    )
//
//    client = Client(delegate: self, dAppInfo: dAppInfo)
//    // Open the web socket connection with the WalletConnect bridge server
//    try! client.connect(to: wcUrl)
//
//    return wcUrl.absoluteString
//  }
//
//  /// Try to restore the previous session with the WalletConnect bridge server
//  func reconnectIfNeeded() -> Void {
//    if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
//       let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
//      client = Client(delegate: self, dAppInfo: session.dAppInfo)
//      try? client.reconnect(to: session)
//    }
//  }
//
//  /// Close the session with the WalletConnect bridge server
//  func disconnect() -> Void {
//    print("sessions count: \(client.openSessions().count)")
//    for session in client.openSessions() {
//      do {
//        try client.disconnect(from: session)
//      } catch {
//        print("Failed to disconnect")
//      }
//    }
//  }
//
//  // MARK: - ClientDelegate functions
//
//  func client(_ client: Client, didFailToConnect url: WCURL) -> Void {
//    self.failedToConnect?()
//  }
//
//  func client(_ client: Client, didConnect url: WCURL) -> Void {
//    // 1st part of the handshake, do nothing
//  }
//
//  func client(_ client: Client, didConnect session: Session) -> Void {
//    // Store the session inside persist app data (UserDefaults here)
//    self.session = session
//    let sessionData = try! JSONEncoder().encode(session)
//    UserDefaults.standard.set(sessionData, forKey: sessionKey)
//
//    // Notify the delegate that the session is successfully open
//    self.didConnect?(session.walletInfo!)
//  }
//
//  func client(_ client: Client, didDisconnect session: Session) -> Void {
//    // Session is not active anymore, remove it from the persisten app data
//    UserDefaults.standard.removeObject(forKey: sessionKey)
//
//    // Notify the subscriber that the session has ended
//    self.didDisconnect?()
//  }
//
//  func client(_ client: Client, didUpdate session: Session) -> Void {
//    // Do nothing
//  }
//}
