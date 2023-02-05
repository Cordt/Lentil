// Lentil
// Created by Laura and Cordt Zermin

import ComposableArchitecture
import Foundation
import WalletConnectSwift
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
      reconnect: WalletConnector.shared.reconnect,
      disconnect: WalletConnector.shared.disconnect,
      sign: WalletConnector.shared.sign,
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
  var connect: () -> ()
  var reconnect: () -> ()
  var disconnect: () -> ()
  var sign: (_ message: String) async throws -> String
  var signData: (_ data: Data) async throws -> Data
}

class WalletConnector {
  private let appTitle = "Lentil App"
  private let appDescription = "The last social media app you'll need."
  private let clientUrl = URL(string: "https://lentil.xyz")!
  
  static let shared: WalletConnector = WalletConnector()
  var eventStream: WalletEvents { WalletConnect.shared.walletEvents }
  // FIXME: Requirement of SigningKey Protocol of XMTP - shouldn't be made available like this
  var address: String { WalletConnect.shared.address }
  
  private init() {}
  
  func connect() {
    guard
      let urlString = try? WalletConnect.shared.connect(title: appTitle, description: appDescription, clientUrl: self.clientUrl),
      let url = URL(string: urlString),
      let deepLink = self.deepLink(for: url)
    else {
      log("Cannot create URL or Deeplink from WCURL", level: .error)
      return
    }
    
    self.open(url: deepLink)
  }
  
  func reconnect() {
    do {
      try WalletConnect.shared.reconnectIfNeeded()
    }
    catch let error {
      log("Failed to reconnect with WC", level: .info, error: error)
    }
  }
  
  func disconnect() {
    do {
      try WalletConnect.shared.disconnect()
    } catch let error {
      log("Could not disconnect from WC", level: .warn, error: error)
    }
  }
  
  func sign(message: String) async throws -> String {
    try await self.prepareToSign()
    return try await WalletConnect.shared.sign(message: message)
  }
  
  func signData(_ data: Data) async throws -> Data {
    try await self.prepareToSign()
    return try await WalletConnect.shared.sign(data: data)
  }
  
  private func prepareToSign() async throws {
    guard
      let urlString = WalletConnect.shared.session?.url.absoluteString,
      let url = URL(string: urlString),
      let deepLink = self.deepLink(for: url)
    else {
      log("Cannot create URL or Deeplink from WCURL", level: .error)
      throw WalletConnectorError.couldNotSignMessage
    }
    
    Task { @MainActor in
      self.open(url: deepLink)
    }
  }
  
  private func deepLink(for url: URL) -> URL? {
    var appendix = url.absoluteString
    appendix = appendix.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    appendix = appendix.replacingOccurrences(of: "=", with: "%3D")
    appendix = appendix.replacingOccurrences(of: "&", with: "%26")
    
    let urlString = "https://metamask.app.link/wc?uri="
      .appending(appendix)
    
    return URL(string: urlString)
  }
  
  private func open(url: URL) {
    guard UIApplication.shared.canOpenURL(url)
    else {
      log("WCURL cannot be opened: \(url.absoluteString)", level: .error)
      return
    }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

fileprivate final class WalletConnect {
  let bridgeUrl = URL(string: "https://bridge.walletconnect.org/")!
  let sessionKey = "walletconnect-session"
  
  let walletEvents: WalletEvents
  var session: Session?
  var client: Client?
  var wcurl: WCURL?
  
  var address: String {
    guard let account = self.session?.walletInfo?.accounts.first
    else { return "" }
    return EthereumAddress(account).toChecksumAddress()
  }
  
  static let shared: WalletConnect = WalletConnect()
  
  private init() {
    self.walletEvents = WalletEvents()
  }
  
  
  func connect(title: String, description: String, clientUrl: URL, icons: [URL] = []) throws -> String {
    let wcUrl =  WCURL(
      topic: UUID().uuidString,
      bridgeURL: self.bridgeUrl,
      key: try randomKey()
    )
    let clientMeta = Session.ClientMeta(
      name: title,
      description: description,
      icons: icons,
      url: clientUrl
    )
    let dAppInfo = Session.DAppInfo(peerId: UUID().uuidString, peerMeta: clientMeta)
    self.client = Client(delegate: self, dAppInfo: dAppInfo)
    
    do {
      try client?.connect(to: wcUrl)
      return wcUrl.absoluteString
      
    } catch let error {
      log("Failed to connect with WC Client", level: .error, error: error)
      throw WalletConnectorError.couldNotConnectClient
    }
  }
  
  func reconnectIfNeeded() throws {
    if let session = self.storedSession() {
      do {
        self.client = Client(delegate: self, dAppInfo: session.dAppInfo)
        try client?.reconnect(to: session)
        
      } catch let error {
        log("Failed to re-connect with WC Client", level: .debug, error: error)
        throw WalletConnectorError.couldNotReconnectClient
      }
    } else {
      log("Failed to re-connect with WC Client: Could not find session object", level: .debug)
      throw WalletConnectorError.couldNotReconnectClient
    }
  }
  
  func disconnect() throws {
    guard let session = self.session,
          let client = self.client
    else { return }
    
    try client.disconnect(from: session)
  }
  
  func sign(message: String) async throws -> String {
    guard let url = self.session?.url
    else { throw WalletConnectorError.couldNotSignMessage }
    
    // Wait for the user to switch to their wallet application
    try await Task.sleep(for: .seconds(2))
    
    return try await withCheckedThrowingContinuation { continuation in
      do {
        try self.client?.personal_sign(
          url: url,
          message: message,
          account: self.address,
          completion: { response in
            guard let signedMessage = try? response.result(as: String.self)
            else {
              log("Failed to sign message with WC Client: \(String(describing: response.error))", level: .error)
              continuation.resume(throwing: WalletConnectorError.couldNotSignMessage)
              return
            }
            continuation.resume(returning: signedMessage)
          }
        )
      }
      catch let error {
        log("Failed to sign message with WC Client", level: .error, error: error)
        continuation.resume(throwing: WalletConnectorError.couldNotSignMessage)
      }
    }
  }
  
  func sign(data: Data) async throws -> Data {
    guard let message = String(data: data, encoding: .utf8)
    else { throw WalletConnectorError.couldNotSignMessage }
    
    var signedMessage = try await self.sign(message: message)
    
    // Strip leading 0x that we get back from `personal_sign`
    if signedMessage.hasPrefix("0x"), signedMessage.count == 132 {
      signedMessage = String(signedMessage.dropFirst(2))
    }
    
    guard let resultDataBytes = signedMessage.web3.bytesFromHex
    else { throw WalletConnectorError.couldNotSignMessage }
    
    var resultData = Data(resultDataBytes)
    
    // Ensure we have a valid recovery byte
    resultData[resultData.count - 1] = 1 - resultData[resultData.count - 1] % 2
    
    return resultData
  }
  
  private func storedSession() -> Session? {
    guard let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
          let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject)
    else { return nil }
    
    return session
  }
  
  // https://developer.apple.com/documentation/security/1399291-secrandomcopybytes
  private func randomKey() throws -> String {
    var bytes = [Int8](repeating: 0, count: 32)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    if status == errSecSuccess {
      return Data(bytes: bytes, count: 32).toHexString()
    } else {
      throw WalletConnectorError.couldNotCreateKey
    }
  }
}

extension WalletConnect: ClientDelegate {
  func client(_ client: Client, didFailToConnect url: WCURL) {
    self.walletEvents.eventsToEmit.append(.didFailToConnect)
    log("Failed to connect to WC", level: .info)
  }
  
  func client(_ client: Client, didConnect url: WCURL) {
    self.wcurl = url
    self.walletEvents.eventsToEmit.append(.didConnect(url))
    log("Successfully connected with WC", level: .info)
  }
  
  func client(_ client: Client, didConnect session: Session) {
    do {
      let encoder = JSONEncoder()
      let encodedSession = try encoder.encode(session)
      UserDefaults.standard.set(encodedSession, forKey: self.sessionKey)
      self.session = session
      self.walletEvents.eventsToEmit.append(.didEstablishSession(session))
      log("Successfully established a session with WC", level: .info)
      
    } catch let error {
      log("Failed to encode WC session", level: .error, error: error)
    }
  }
  
  func client(_ client: Client, didDisconnect session: Session) {
    UserDefaults.standard.removeObject(forKey: self.sessionKey)
    self.walletEvents.eventsToEmit.append(.didDisconnect)
    log("Successfully disconeccted from WC", level: .info)
  }
  
  func client(_ client: Client, didUpdate session: Session) {
    self.walletEvents.eventsToEmit.append(.didUpdate(session))
    log("Updated WC Session", level: .info)
  }
}



class WalletEvents: AsyncSequence, AsyncIteratorProtocol {
  enum Event {
    case didFailToConnect
    case didConnect(WCURL)
    case didEstablishSession(Session)
    case didDisconnect
    case didUpdate(Session)
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
