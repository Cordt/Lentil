// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class PingQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Ping {
      ping
    }
    """

  public let operationName: String = "Ping"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("ping", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(ping: String) {
      self.init(unsafeResultMap: ["__typename": "Query", "ping": ping])
    }

    public var ping: String {
      get {
        return resultMap["ping"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "ping")
      }
    }
  }
}
