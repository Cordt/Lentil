// Lentil

import ComposableArchitecture
import Foundation
import WalletConnectSwift
import UIKit


enum WalletConnectorError: Error {
  case couldNotCreateKey
  case couldNotConnectClient
  case couldNotReconnectClient
  case couldNotSignMessage
}

extension WalletConnectorApi: DependencyKey {
  static var liveValue: WalletConnectorApi {
    WalletConnectorApi(
      connect: WalletConnector.shared.connect,
      sign: WalletConnector.shared.sign
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
  var connect: () -> ()
  var sign: (_ message: String) async throws -> String
}

fileprivate final class WalletConnector {
  private let appTitle = "Lentil App"
  private let appDescription = "The last social media app you'll need."
  private let clientUrl = URL(string: "https://lentil.xyz")!
  
  static let shared: WalletConnector = WalletConnector()
  private init() {}
  
  func connect() {
    guard
      let urlString = try? WalletConnect.shared.connect(title: appTitle, description: appDescription, clientUrl: self.clientUrl),
      let url = URL(string: urlString),
      let deepLink = self.deepLink(for: url)
    else {
      print("[ERROR] Cannot create URL or Deeplink from WCURL")
      return
    }
    
    self.open(url: deepLink)
  }
  
  func sign(message: String) async throws -> String {
    let urlString = try WalletConnect.shared.reconnectIfNeeded()
    guard
      let url = URL(string: urlString),
      let deepLink = self.deepLink(for: url)
    else {
      print("[ERROR] Cannot create URL or Deeplink from WCURL")
      throw WalletConnectorError.couldNotSignMessage
    }
    
    Task { @MainActor in
      self.open(url: deepLink)
    }
    
    return try await WalletConnect.shared.sign(message: message)
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
      print("[ERROR] WCURL cannot be opened: \(url.absoluteString)")
      return
    }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

fileprivate final class WalletConnect {
  let bridgeUrl = URL(string: "https://safe-walletconnect.safe.global/")!
  let sessionKey = "walletconnect-session"
  
  var session: Session?
  var client: Client?
  var wcurl: WCURL?
  
  static let shared: WalletConnect = WalletConnect()
  private init() {}
  
  
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
      print("[ERROR] Failed to connect with WC Client: \(error)")
      throw WalletConnectorError.couldNotConnectClient
    }
  }
  
  func reconnectIfNeeded() throws -> String {
    if let oldSessionObject = UserDefaults.standard.object(forKey: sessionKey) as? Data,
       let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject) {
      
      do {
        self.client = Client(delegate: self, dAppInfo: session.dAppInfo)
        try client?.reconnect(to: session)
        return session.url.absoluteString
        
      } catch let error {
        print("[ERROR] Failed to re-connect with WC Client: \(error)")
        throw WalletConnectorError.couldNotReconnectClient
      }
    } else {
      print("[ERROR] Failed to re-connect with WC Client: Could not find session object")
      throw WalletConnectorError.couldNotReconnectClient
    }
  }
  
  func sign(message: String) async throws -> String {
    guard let accounts = self.session?.walletInfo?.accounts,
          let wallet = accounts.first,
          let url = self.session?.url
    else { throw WalletConnectorError.couldNotSignMessage }
    
    // Wait for the user to switch to their wallet application
    try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
    
    return try await withCheckedThrowingContinuation { continuation in
      do {
        try self.client?.personal_sign(
          url: url,
          message: message,
          account: wallet,
          completion: { response in
            guard let signedMessage = try? response.result(as: String.self)
            else {
              print("[ERROR] Failed to sign message with WC Client: \(String(describing: response.error))")
              continuation.resume(throwing: WalletConnectorError.couldNotSignMessage)
              return
            }
            continuation.resume(returning: signedMessage)
          }
        )
      }
      catch let error {
        print("[ERROR] Failed to sign message with WC Client: \(error)")
        continuation.resume(throwing: WalletConnectorError.couldNotSignMessage)
      }
    }
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
    print("[INFO] Failed to connect to WC")
  }
  
  func client(_ client: Client, didConnect url: WCURL) {
    self.wcurl = url
    print("[INFO] Successfully connected with WC")
  }
  
  func client(_ client: Client, didConnect session: Session) {
    do {
      let encoder = JSONEncoder()
      let encodedSession = try encoder.encode(session)
      UserDefaults.standard.set(encodedSession, forKey: self.sessionKey)
      self.session = session
      print("[INFO] Successfully established a session with WC")
      
    } catch let error {
      print("[ERROR] Failed to encode WC session: \(error)")
    }
  }
  
  func client(_ client: Client, didDisconnect session: Session) {
    UserDefaults.standard.removeObject(forKey: self.sessionKey)
    print("[INFO] Successfully disconeccted from WC")
  }
  
  func client(_ client: Client, didUpdate session: Session) {
    print("[INFO] Updated WC Session")
  }
}


