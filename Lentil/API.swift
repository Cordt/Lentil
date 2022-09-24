// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct ExplorePublicationRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - limit
  ///   - cursor
  ///   - timestamp
  ///   - sortCriteria
  ///   - sources: The App Id
  ///   - publicationTypes: The publication types you want to query
  ///   - noRandomize: If you want the randomizer off (default on)
  ///   - excludeProfileIds: If you wish to exclude any results for profile ids
  ///   - metadata
  public init(limit: Swift.Optional<String?> = nil, cursor: Swift.Optional<String?> = nil, timestamp: Swift.Optional<String?> = nil, sortCriteria: PublicationSortCriteria, sources: Swift.Optional<[String]?> = nil, publicationTypes: Swift.Optional<[PublicationTypes]?> = nil, noRandomize: Swift.Optional<Bool?> = nil, excludeProfileIds: Swift.Optional<[String]?> = nil, metadata: Swift.Optional<PublicationMetadataFilters?> = nil) {
    graphQLMap = ["limit": limit, "cursor": cursor, "timestamp": timestamp, "sortCriteria": sortCriteria, "sources": sources, "publicationTypes": publicationTypes, "noRandomize": noRandomize, "excludeProfileIds": excludeProfileIds, "metadata": metadata]
  }

  public var limit: Swift.Optional<String?> {
    get {
      return graphQLMap["limit"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "limit")
    }
  }

  public var cursor: Swift.Optional<String?> {
    get {
      return graphQLMap["cursor"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "cursor")
    }
  }

  public var timestamp: Swift.Optional<String?> {
    get {
      return graphQLMap["timestamp"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }

  public var sortCriteria: PublicationSortCriteria {
    get {
      return graphQLMap["sortCriteria"] as! PublicationSortCriteria
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sortCriteria")
    }
  }

  /// The App Id
  public var sources: Swift.Optional<[String]?> {
    get {
      return graphQLMap["sources"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sources")
    }
  }

  /// The publication types you want to query
  public var publicationTypes: Swift.Optional<[PublicationTypes]?> {
    get {
      return graphQLMap["publicationTypes"] as? Swift.Optional<[PublicationTypes]?> ?? Swift.Optional<[PublicationTypes]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "publicationTypes")
    }
  }

  /// If you want the randomizer off (default on)
  public var noRandomize: Swift.Optional<Bool?> {
    get {
      return graphQLMap["noRandomize"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "noRandomize")
    }
  }

  /// If you wish to exclude any results for profile ids
  public var excludeProfileIds: Swift.Optional<[String]?> {
    get {
      return graphQLMap["excludeProfileIds"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "excludeProfileIds")
    }
  }

  public var metadata: Swift.Optional<PublicationMetadataFilters?> {
    get {
      return graphQLMap["metadata"] as? Swift.Optional<PublicationMetadataFilters?> ?? Swift.Optional<PublicationMetadataFilters?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "metadata")
    }
  }
}

/// Publication sort criteria
public enum PublicationSortCriteria: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case topCommented
  case topCollected
  case topMirrored
  case curatedProfiles
  case latest
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "TOP_COMMENTED": self = .topCommented
      case "TOP_COLLECTED": self = .topCollected
      case "TOP_MIRRORED": self = .topMirrored
      case "CURATED_PROFILES": self = .curatedProfiles
      case "LATEST": self = .latest
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .topCommented: return "TOP_COMMENTED"
      case .topCollected: return "TOP_COLLECTED"
      case .topMirrored: return "TOP_MIRRORED"
      case .curatedProfiles: return "CURATED_PROFILES"
      case .latest: return "LATEST"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PublicationSortCriteria, rhs: PublicationSortCriteria) -> Bool {
    switch (lhs, rhs) {
      case (.topCommented, .topCommented): return true
      case (.topCollected, .topCollected): return true
      case (.topMirrored, .topMirrored): return true
      case (.curatedProfiles, .curatedProfiles): return true
      case (.latest, .latest): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PublicationSortCriteria] {
    return [
      .topCommented,
      .topCollected,
      .topMirrored,
      .curatedProfiles,
      .latest,
    ]
  }
}

/// The publication types
public enum PublicationTypes: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case post
  case comment
  case mirror
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "POST": self = .post
      case "COMMENT": self = .comment
      case "MIRROR": self = .mirror
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .post: return "POST"
      case .comment: return "COMMENT"
      case .mirror: return "MIRROR"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PublicationTypes, rhs: PublicationTypes) -> Bool {
    switch (lhs, rhs) {
      case (.post, .post): return true
      case (.comment, .comment): return true
      case (.mirror, .mirror): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PublicationTypes] {
    return [
      .post,
      .comment,
      .mirror,
    ]
  }
}

/// Publication metadata filters
public struct PublicationMetadataFilters: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - locale: IOS 639-1 language code aka en or it and ISO 3166-1 alpha-2 region code aka US or IT aka en-US or it-IT. You can just filter on language if you wish.
  ///   - contentWarning
  ///   - mainContentFocus
  ///   - tags
  public init(locale: Swift.Optional<String?> = nil, contentWarning: Swift.Optional<PublicationMetadataContentWarningFilter?> = nil, mainContentFocus: Swift.Optional<[PublicationMainFocus]?> = nil, tags: Swift.Optional<PublicationMetadataTagsFilter?> = nil) {
    graphQLMap = ["locale": locale, "contentWarning": contentWarning, "mainContentFocus": mainContentFocus, "tags": tags]
  }

  /// IOS 639-1 language code aka en or it and ISO 3166-1 alpha-2 region code aka US or IT aka en-US or it-IT. You can just filter on language if you wish.
  public var locale: Swift.Optional<String?> {
    get {
      return graphQLMap["locale"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "locale")
    }
  }

  public var contentWarning: Swift.Optional<PublicationMetadataContentWarningFilter?> {
    get {
      return graphQLMap["contentWarning"] as? Swift.Optional<PublicationMetadataContentWarningFilter?> ?? Swift.Optional<PublicationMetadataContentWarningFilter?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contentWarning")
    }
  }

  public var mainContentFocus: Swift.Optional<[PublicationMainFocus]?> {
    get {
      return graphQLMap["mainContentFocus"] as? Swift.Optional<[PublicationMainFocus]?> ?? Swift.Optional<[PublicationMainFocus]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mainContentFocus")
    }
  }

  public var tags: Swift.Optional<PublicationMetadataTagsFilter?> {
    get {
      return graphQLMap["tags"] as? Swift.Optional<PublicationMetadataTagsFilter?> ?? Swift.Optional<PublicationMetadataTagsFilter?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tags")
    }
  }
}

/// Publication metadata content waring filters
public struct PublicationMetadataContentWarningFilter: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - includeOneOf: By default all content warnings will be hidden you can include them in your query by adding them to this array.
  public init(includeOneOf: Swift.Optional<[PublicationContentWarning]?> = nil) {
    graphQLMap = ["includeOneOf": includeOneOf]
  }

  /// By default all content warnings will be hidden you can include them in your query by adding them to this array.
  public var includeOneOf: Swift.Optional<[PublicationContentWarning]?> {
    get {
      return graphQLMap["includeOneOf"] as? Swift.Optional<[PublicationContentWarning]?> ?? Swift.Optional<[PublicationContentWarning]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "includeOneOf")
    }
  }
}

/// The publication content warning
public enum PublicationContentWarning: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case nsfw
  case sensitive
  case spoiler
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NSFW": self = .nsfw
      case "SENSITIVE": self = .sensitive
      case "SPOILER": self = .spoiler
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .nsfw: return "NSFW"
      case .sensitive: return "SENSITIVE"
      case .spoiler: return "SPOILER"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PublicationContentWarning, rhs: PublicationContentWarning) -> Bool {
    switch (lhs, rhs) {
      case (.nsfw, .nsfw): return true
      case (.sensitive, .sensitive): return true
      case (.spoiler, .spoiler): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PublicationContentWarning] {
    return [
      .nsfw,
      .sensitive,
      .spoiler,
    ]
  }
}

/// The publication main focus
public enum PublicationMainFocus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case video
  case image
  case article
  case textOnly
  case audio
  case link
  case embed
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "VIDEO": self = .video
      case "IMAGE": self = .image
      case "ARTICLE": self = .article
      case "TEXT_ONLY": self = .textOnly
      case "AUDIO": self = .audio
      case "LINK": self = .link
      case "EMBED": self = .embed
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .video: return "VIDEO"
      case .image: return "IMAGE"
      case .article: return "ARTICLE"
      case .textOnly: return "TEXT_ONLY"
      case .audio: return "AUDIO"
      case .link: return "LINK"
      case .embed: return "EMBED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PublicationMainFocus, rhs: PublicationMainFocus) -> Bool {
    switch (lhs, rhs) {
      case (.video, .video): return true
      case (.image, .image): return true
      case (.article, .article): return true
      case (.textOnly, .textOnly): return true
      case (.audio, .audio): return true
      case (.link, .link): return true
      case (.embed, .embed): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PublicationMainFocus] {
    return [
      .video,
      .image,
      .article,
      .textOnly,
      .audio,
      .link,
      .embed,
    ]
  }
}

/// Publication metadata tag filter
public struct PublicationMetadataTagsFilter: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - oneOf: Needs to only match one of
  ///   - all: Needs to only match all
  public init(oneOf: Swift.Optional<[String]?> = nil, all: Swift.Optional<[String]?> = nil) {
    graphQLMap = ["oneOf": oneOf, "all": all]
  }

  /// Needs to only match one of
  public var oneOf: Swift.Optional<[String]?> {
    get {
      return graphQLMap["oneOf"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "oneOf")
    }
  }

  /// Needs to only match all
  public var all: Swift.Optional<[String]?> {
    get {
      return graphQLMap["all"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "all")
    }
  }
}

public struct PublicationsQueryRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - limit
  ///   - cursor
  ///   - profileId: Profile id
  ///   - publicationTypes: The publication types you want to query
  ///   - commentsOf: The publication id you wish to get comments for
  ///   - sources: The App Id
  ///   - collectedBy: The ethereum address
  ///   - publicationIds: The publication id
  ///   - metadata
  public init(limit: Swift.Optional<String?> = nil, cursor: Swift.Optional<String?> = nil, profileId: Swift.Optional<String?> = nil, publicationTypes: Swift.Optional<[PublicationTypes]?> = nil, commentsOf: Swift.Optional<String?> = nil, sources: Swift.Optional<[String]?> = nil, collectedBy: Swift.Optional<String?> = nil, publicationIds: Swift.Optional<[String]?> = nil, metadata: Swift.Optional<PublicationMetadataFilters?> = nil) {
    graphQLMap = ["limit": limit, "cursor": cursor, "profileId": profileId, "publicationTypes": publicationTypes, "commentsOf": commentsOf, "sources": sources, "collectedBy": collectedBy, "publicationIds": publicationIds, "metadata": metadata]
  }

  public var limit: Swift.Optional<String?> {
    get {
      return graphQLMap["limit"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "limit")
    }
  }

  public var cursor: Swift.Optional<String?> {
    get {
      return graphQLMap["cursor"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "cursor")
    }
  }

  /// Profile id
  public var profileId: Swift.Optional<String?> {
    get {
      return graphQLMap["profileId"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "profileId")
    }
  }

  /// The publication types you want to query
  public var publicationTypes: Swift.Optional<[PublicationTypes]?> {
    get {
      return graphQLMap["publicationTypes"] as? Swift.Optional<[PublicationTypes]?> ?? Swift.Optional<[PublicationTypes]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "publicationTypes")
    }
  }

  /// The publication id you wish to get comments for
  public var commentsOf: Swift.Optional<String?> {
    get {
      return graphQLMap["commentsOf"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "commentsOf")
    }
  }

  /// The App Id
  public var sources: Swift.Optional<[String]?> {
    get {
      return graphQLMap["sources"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sources")
    }
  }

  /// The ethereum address
  public var collectedBy: Swift.Optional<String?> {
    get {
      return graphQLMap["collectedBy"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "collectedBy")
    }
  }

  /// The publication id
  public var publicationIds: Swift.Optional<[String]?> {
    get {
      return graphQLMap["publicationIds"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "publicationIds")
    }
  }

  public var metadata: Swift.Optional<PublicationMetadataFilters?> {
    get {
      return graphQLMap["metadata"] as? Swift.Optional<PublicationMetadataFilters?> ?? Swift.Optional<PublicationMetadataFilters?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "metadata")
    }
  }
}

/// The follow module types
public enum FollowModules: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case feeFollowModule
  case revertFollowModule
  case profileFollowModule
  case unknownFollowModule
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "FeeFollowModule": self = .feeFollowModule
      case "RevertFollowModule": self = .revertFollowModule
      case "ProfileFollowModule": self = .profileFollowModule
      case "UnknownFollowModule": self = .unknownFollowModule
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .feeFollowModule: return "FeeFollowModule"
      case .revertFollowModule: return "RevertFollowModule"
      case .profileFollowModule: return "ProfileFollowModule"
      case .unknownFollowModule: return "UnknownFollowModule"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: FollowModules, rhs: FollowModules) -> Bool {
    switch (lhs, rhs) {
      case (.feeFollowModule, .feeFollowModule): return true
      case (.revertFollowModule, .revertFollowModule): return true
      case (.profileFollowModule, .profileFollowModule): return true
      case (.unknownFollowModule, .unknownFollowModule): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [FollowModules] {
    return [
      .feeFollowModule,
      .revertFollowModule,
      .profileFollowModule,
      .unknownFollowModule,
    ]
  }
}

/// The publication metadata display types
public enum PublicationMetadataDisplayTypes: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case number
  case string
  case date
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "number": self = .number
      case "string": self = .string
      case "date": self = .date
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .number: return "number"
      case .string: return "string"
      case .date: return "date"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PublicationMetadataDisplayTypes, rhs: PublicationMetadataDisplayTypes) -> Bool {
    switch (lhs, rhs) {
      case (.number, .number): return true
      case (.string, .string): return true
      case (.date, .date): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PublicationMetadataDisplayTypes] {
    return [
      .number,
      .string,
      .date,
    ]
  }
}

/// The collect module types
public enum CollectModules: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case limitedFeeCollectModule
  case feeCollectModule
  case limitedTimedFeeCollectModule
  case timedFeeCollectModule
  case revertCollectModule
  case freeCollectModule
  case unknownCollectModule
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "LimitedFeeCollectModule": self = .limitedFeeCollectModule
      case "FeeCollectModule": self = .feeCollectModule
      case "LimitedTimedFeeCollectModule": self = .limitedTimedFeeCollectModule
      case "TimedFeeCollectModule": self = .timedFeeCollectModule
      case "RevertCollectModule": self = .revertCollectModule
      case "FreeCollectModule": self = .freeCollectModule
      case "UnknownCollectModule": self = .unknownCollectModule
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .limitedFeeCollectModule: return "LimitedFeeCollectModule"
      case .feeCollectModule: return "FeeCollectModule"
      case .limitedTimedFeeCollectModule: return "LimitedTimedFeeCollectModule"
      case .timedFeeCollectModule: return "TimedFeeCollectModule"
      case .revertCollectModule: return "RevertCollectModule"
      case .freeCollectModule: return "FreeCollectModule"
      case .unknownCollectModule: return "UnknownCollectModule"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CollectModules, rhs: CollectModules) -> Bool {
    switch (lhs, rhs) {
      case (.limitedFeeCollectModule, .limitedFeeCollectModule): return true
      case (.feeCollectModule, .feeCollectModule): return true
      case (.limitedTimedFeeCollectModule, .limitedTimedFeeCollectModule): return true
      case (.timedFeeCollectModule, .timedFeeCollectModule): return true
      case (.revertCollectModule, .revertCollectModule): return true
      case (.freeCollectModule, .freeCollectModule): return true
      case (.unknownCollectModule, .unknownCollectModule): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CollectModules] {
    return [
      .limitedFeeCollectModule,
      .feeCollectModule,
      .limitedTimedFeeCollectModule,
      .timedFeeCollectModule,
      .revertCollectModule,
      .freeCollectModule,
      .unknownCollectModule,
    ]
  }
}

/// The reference module types
public enum ReferenceModules: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case followerOnlyReferenceModule
  case unknownReferenceModule
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "FollowerOnlyReferenceModule": self = .followerOnlyReferenceModule
      case "UnknownReferenceModule": self = .unknownReferenceModule
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .followerOnlyReferenceModule: return "FollowerOnlyReferenceModule"
      case .unknownReferenceModule: return "UnknownReferenceModule"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ReferenceModules, rhs: ReferenceModules) -> Bool {
    switch (lhs, rhs) {
      case (.followerOnlyReferenceModule, .followerOnlyReferenceModule): return true
      case (.unknownReferenceModule, .unknownReferenceModule): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ReferenceModules] {
    return [
      .followerOnlyReferenceModule,
      .unknownReferenceModule,
    ]
  }
}

/// Reaction types
public enum ReactionTypes: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case upvote
  case downvote
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "UPVOTE": self = .upvote
      case "DOWNVOTE": self = .downvote
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .upvote: return "UPVOTE"
      case .downvote: return "DOWNVOTE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: ReactionTypes, rhs: ReactionTypes) -> Bool {
    switch (lhs, rhs) {
      case (.upvote, .upvote): return true
      case (.downvote, .downvote): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [ReactionTypes] {
    return [
      .upvote,
      .downvote,
    ]
  }
}

public final class ExplorePublicationsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query ExplorePublications($request: ExplorePublicationRequest!) {
      explorePublications(request: $request) {
        __typename
        items {
          __typename
          ... on Post {
            __typename
            ...PostFields
          }
          ... on Comment {
            __typename
            ...CommentFields
          }
          ... on Mirror {
            __typename
            ...MirrorFields
          }
        }
        pageInfo {
          __typename
          prev
          next
          totalCount
        }
      }
    }
    """

  public let operationName: String = "ExplorePublications"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + PostFields.fragmentDefinition)
    document.append("\n" + ProfileFields.fragmentDefinition)
    document.append("\n" + MediaFields.fragmentDefinition)
    document.append("\n" + PublicationStatsFields.fragmentDefinition)
    document.append("\n" + MetadataOutputFields.fragmentDefinition)
    document.append("\n" + CollectModuleFields.fragmentDefinition)
    document.append("\n" + Erc20Fields.fragmentDefinition)
    document.append("\n" + CommentFields.fragmentDefinition)
    document.append("\n" + CommentBaseFields.fragmentDefinition)
    document.append("\n" + MirrorBaseFields.fragmentDefinition)
    document.append("\n" + CommentMirrorOfFields.fragmentDefinition)
    document.append("\n" + MirrorFields.fragmentDefinition)
    return document
  }

  public var request: ExplorePublicationRequest

  public init(request: ExplorePublicationRequest) {
    self.request = request
  }

  public var variables: GraphQLMap? {
    return ["request": request]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("explorePublications", arguments: ["request": GraphQLVariable("request")], type: .nonNull(.object(ExplorePublication.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(explorePublications: ExplorePublication) {
      self.init(unsafeResultMap: ["__typename": "Query", "explorePublications": explorePublications.resultMap])
    }

    public var explorePublications: ExplorePublication {
      get {
        return ExplorePublication(unsafeResultMap: resultMap["explorePublications"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "explorePublications")
      }
    }

    public struct ExplorePublication: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ExplorePublicationResult"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
          GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(items: [Item], pageInfo: PageInfo) {
        self.init(unsafeResultMap: ["__typename": "ExplorePublicationResult", "items": items.map { (value: Item) -> ResultMap in value.resultMap }, "pageInfo": pageInfo.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (resultMap["items"] as! [ResultMap]).map { (value: ResultMap) -> Item in Item(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Item) -> ResultMap in value.resultMap }, forKey: "items")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Post", "Comment", "Mirror"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Post": AsPost.selections, "Comment": AsComment.selections, "Mirror": AsMirror.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asPost: AsPost? {
          get {
            if !AsPost.possibleTypes.contains(__typename) { return nil }
            return AsPost(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPost: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Post"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(PostFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var postFields: PostFields {
              get {
                return PostFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asComment: AsComment? {
          get {
            if !AsComment.possibleTypes.contains(__typename) { return nil }
            return AsComment(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsComment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Comment"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(CommentFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var commentFields: CommentFields {
              get {
                return CommentFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMirror: AsMirror? {
          get {
            if !AsMirror.possibleTypes.contains(__typename) { return nil }
            return AsMirror(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMirror: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Mirror"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(MirrorFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var mirrorFields: MirrorFields {
              get {
                return MirrorFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PaginatedResultInfo"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("prev", type: .scalar(String.self)),
            GraphQLField("next", type: .scalar(String.self)),
            GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(prev: String? = nil, next: String? = nil, totalCount: Int) {
          self.init(unsafeResultMap: ["__typename": "PaginatedResultInfo", "prev": prev, "next": next, "totalCount": totalCount])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Cursor to query the actual results
        public var prev: String? {
          get {
            return resultMap["prev"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "prev")
          }
        }

        /// Cursor to query next results
        public var next: String? {
          get {
            return resultMap["next"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "next")
          }
        }

        /// The total number of entities the pagination iterates over. e.g. For a query that requests all nfts with more than 10 likes, this field gives the total amount of nfts with more than 10 likes, not the total amount of nfts
        public var totalCount: Int {
          get {
            return resultMap["totalCount"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "totalCount")
          }
        }
      }
    }
  }
}

public final class PublicationsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Publications($request: PublicationsQueryRequest!) {
      publications(request: $request) {
        __typename
        items {
          __typename
          ... on Post {
            __typename
            ...PostFields
          }
          ... on Comment {
            __typename
            ...CommentFields
          }
          ... on Mirror {
            __typename
            ...MirrorFields
          }
        }
        pageInfo {
          __typename
          prev
          next
          totalCount
        }
      }
    }
    """

  public let operationName: String = "Publications"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + PostFields.fragmentDefinition)
    document.append("\n" + ProfileFields.fragmentDefinition)
    document.append("\n" + MediaFields.fragmentDefinition)
    document.append("\n" + PublicationStatsFields.fragmentDefinition)
    document.append("\n" + MetadataOutputFields.fragmentDefinition)
    document.append("\n" + CollectModuleFields.fragmentDefinition)
    document.append("\n" + Erc20Fields.fragmentDefinition)
    document.append("\n" + CommentFields.fragmentDefinition)
    document.append("\n" + CommentBaseFields.fragmentDefinition)
    document.append("\n" + MirrorBaseFields.fragmentDefinition)
    document.append("\n" + CommentMirrorOfFields.fragmentDefinition)
    document.append("\n" + MirrorFields.fragmentDefinition)
    return document
  }

  public var request: PublicationsQueryRequest

  public init(request: PublicationsQueryRequest) {
    self.request = request
  }

  public var variables: GraphQLMap? {
    return ["request": request]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("publications", arguments: ["request": GraphQLVariable("request")], type: .nonNull(.object(Publication.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(publications: Publication) {
      self.init(unsafeResultMap: ["__typename": "Query", "publications": publications.resultMap])
    }

    public var publications: Publication {
      get {
        return Publication(unsafeResultMap: resultMap["publications"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "publications")
      }
    }

    public struct Publication: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PaginatedPublicationResult"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
          GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(items: [Item], pageInfo: PageInfo) {
        self.init(unsafeResultMap: ["__typename": "PaginatedPublicationResult", "items": items.map { (value: Item) -> ResultMap in value.resultMap }, "pageInfo": pageInfo.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (resultMap["items"] as! [ResultMap]).map { (value: ResultMap) -> Item in Item(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Item) -> ResultMap in value.resultMap }, forKey: "items")
        }
      }

      public var pageInfo: PageInfo {
        get {
          return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Post", "Comment", "Mirror"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Post": AsPost.selections, "Comment": AsComment.selections, "Mirror": AsMirror.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asPost: AsPost? {
          get {
            if !AsPost.possibleTypes.contains(__typename) { return nil }
            return AsPost(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPost: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Post"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(PostFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var postFields: PostFields {
              get {
                return PostFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asComment: AsComment? {
          get {
            if !AsComment.possibleTypes.contains(__typename) { return nil }
            return AsComment(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsComment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Comment"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(CommentFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var commentFields: CommentFields {
              get {
                return CommentFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMirror: AsMirror? {
          get {
            if !AsMirror.possibleTypes.contains(__typename) { return nil }
            return AsMirror(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMirror: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Mirror"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(MirrorFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var mirrorFields: MirrorFields {
              get {
                return MirrorFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PaginatedResultInfo"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("prev", type: .scalar(String.self)),
            GraphQLField("next", type: .scalar(String.self)),
            GraphQLField("totalCount", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(prev: String? = nil, next: String? = nil, totalCount: Int) {
          self.init(unsafeResultMap: ["__typename": "PaginatedResultInfo", "prev": prev, "next": next, "totalCount": totalCount])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Cursor to query the actual results
        public var prev: String? {
          get {
            return resultMap["prev"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "prev")
          }
        }

        /// Cursor to query next results
        public var next: String? {
          get {
            return resultMap["next"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "next")
          }
        }

        /// The total number of entities the pagination iterates over. e.g. For a query that requests all nfts with more than 10 likes, this field gives the total amount of nfts with more than 10 likes, not the total amount of nfts
        public var totalCount: Int {
          get {
            return resultMap["totalCount"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "totalCount")
          }
        }
      }
    }
  }
}

public struct MediaFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MediaFields on Media {
      __typename
      url
      width
      height
      mimeType
    }
    """

  public static let possibleTypes: [String] = ["Media"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("url", type: .nonNull(.scalar(String.self))),
      GraphQLField("width", type: .scalar(Int.self)),
      GraphQLField("height", type: .scalar(Int.self)),
      GraphQLField("mimeType", type: .scalar(String.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
    self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The token image nft
  public var url: String {
    get {
      return resultMap["url"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "url")
    }
  }

  /// Width - will always be null on the public API
  public var width: Int? {
    get {
      return resultMap["width"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "width")
    }
  }

  /// Height - will always be null on the public API
  public var height: Int? {
    get {
      return resultMap["height"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "height")
    }
  }

  /// The image/audio/video mime type for the publication
  public var mimeType: String? {
    get {
      return resultMap["mimeType"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "mimeType")
    }
  }
}

public struct ProfileFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ProfileFields on Profile {
      __typename
      id
      name
      bio
      attributes {
        __typename
        displayType
        traitType
        key
        value
      }
      isFollowedByMe
      isFollowing(who: null)
      followNftAddress
      metadata
      isDefault
      handle
      picture {
        __typename
        ... on NftImage {
          __typename
          contractAddress
          tokenId
          uri
          verified
        }
        ... on MediaSet {
          __typename
          original {
            __typename
            ...MediaFields
          }
          small {
            __typename
            ...MediaFields
          }
          medium {
            __typename
            ...MediaFields
          }
        }
      }
      coverPicture {
        __typename
        ... on NftImage {
          __typename
          contractAddress
          tokenId
          uri
          verified
        }
        ... on MediaSet {
          __typename
          original {
            __typename
            ...MediaFields
          }
          small {
            __typename
            ...MediaFields
          }
          medium {
            __typename
            ...MediaFields
          }
        }
      }
      ownedBy
      dispatcher {
        __typename
        address
      }
      stats {
        __typename
        totalFollowers
        totalFollowing
        totalPosts
        totalComments
        totalMirrors
        totalPublications
        totalCollects
      }
      followModule {
        __typename
        ... on FeeFollowModuleSettings {
          __typename
          type
          amount {
            __typename
            asset {
              __typename
              name
              symbol
              decimals
              address
            }
            value
          }
          recipient
        }
        ... on ProfileFollowModuleSettings {
          __typename
          type
        }
        ... on RevertFollowModuleSettings {
          __typename
          type
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Profile"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .scalar(String.self)),
      GraphQLField("bio", type: .scalar(String.self)),
      GraphQLField("attributes", type: .list(.nonNull(.object(Attribute.selections)))),
      GraphQLField("isFollowedByMe", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("isFollowing", arguments: ["who": nil], type: .nonNull(.scalar(Bool.self))),
      GraphQLField("followNftAddress", type: .scalar(String.self)),
      GraphQLField("metadata", type: .scalar(String.self)),
      GraphQLField("isDefault", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("handle", type: .nonNull(.scalar(String.self))),
      GraphQLField("picture", type: .object(Picture.selections)),
      GraphQLField("coverPicture", type: .object(CoverPicture.selections)),
      GraphQLField("ownedBy", type: .nonNull(.scalar(String.self))),
      GraphQLField("dispatcher", type: .object(Dispatcher.selections)),
      GraphQLField("stats", type: .nonNull(.object(Stat.selections))),
      GraphQLField("followModule", type: .object(FollowModule.selections)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, name: String? = nil, bio: String? = nil, attributes: [Attribute]? = nil, isFollowedByMe: Bool, isFollowing: Bool, followNftAddress: String? = nil, metadata: String? = nil, isDefault: Bool, handle: String, picture: Picture? = nil, coverPicture: CoverPicture? = nil, ownedBy: String, dispatcher: Dispatcher? = nil, stats: Stat, followModule: FollowModule? = nil) {
    self.init(unsafeResultMap: ["__typename": "Profile", "id": id, "name": name, "bio": bio, "attributes": attributes.flatMap { (value: [Attribute]) -> [ResultMap] in value.map { (value: Attribute) -> ResultMap in value.resultMap } }, "isFollowedByMe": isFollowedByMe, "isFollowing": isFollowing, "followNftAddress": followNftAddress, "metadata": metadata, "isDefault": isDefault, "handle": handle, "picture": picture.flatMap { (value: Picture) -> ResultMap in value.resultMap }, "coverPicture": coverPicture.flatMap { (value: CoverPicture) -> ResultMap in value.resultMap }, "ownedBy": ownedBy, "dispatcher": dispatcher.flatMap { (value: Dispatcher) -> ResultMap in value.resultMap }, "stats": stats.resultMap, "followModule": followModule.flatMap { (value: FollowModule) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The profile id
  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// Name of the profile
  public var name: String? {
    get {
      return resultMap["name"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// Bio of the profile
  public var bio: String? {
    get {
      return resultMap["bio"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "bio")
    }
  }

  /// Optionals param to add extra attributes on the metadata
  public var attributes: [Attribute]? {
    get {
      return (resultMap["attributes"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Attribute] in value.map { (value: ResultMap) -> Attribute in Attribute(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Attribute]) -> [ResultMap] in value.map { (value: Attribute) -> ResultMap in value.resultMap } }, forKey: "attributes")
    }
  }

  public var isFollowedByMe: Bool {
    get {
      return resultMap["isFollowedByMe"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isFollowedByMe")
    }
  }

  public var isFollowing: Bool {
    get {
      return resultMap["isFollowing"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isFollowing")
    }
  }

  /// Follow nft address
  public var followNftAddress: String? {
    get {
      return resultMap["followNftAddress"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "followNftAddress")
    }
  }

  /// Metadata url
  public var metadata: String? {
    get {
      return resultMap["metadata"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "metadata")
    }
  }

  /// Is the profile default
  public var isDefault: Bool {
    get {
      return resultMap["isDefault"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isDefault")
    }
  }

  /// The profile handle
  public var handle: String {
    get {
      return resultMap["handle"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "handle")
    }
  }

  /// The picture for the profile
  public var picture: Picture? {
    get {
      return (resultMap["picture"] as? ResultMap).flatMap { Picture(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "picture")
    }
  }

  /// The cover picture for the profile
  public var coverPicture: CoverPicture? {
    get {
      return (resultMap["coverPicture"] as? ResultMap).flatMap { CoverPicture(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "coverPicture")
    }
  }

  /// Who owns the profile
  public var ownedBy: String {
    get {
      return resultMap["ownedBy"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "ownedBy")
    }
  }

  /// The dispatcher
  public var dispatcher: Dispatcher? {
    get {
      return (resultMap["dispatcher"] as? ResultMap).flatMap { Dispatcher(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "dispatcher")
    }
  }

  /// Profile stats
  public var stats: Stat {
    get {
      return Stat(unsafeResultMap: resultMap["stats"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "stats")
    }
  }

  /// The follow module
  public var followModule: FollowModule? {
    get {
      return (resultMap["followModule"] as? ResultMap).flatMap { FollowModule(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "followModule")
    }
  }

  public struct Attribute: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Attribute"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("displayType", type: .scalar(String.self)),
        GraphQLField("traitType", type: .scalar(String.self)),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("value", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(displayType: String? = nil, traitType: String? = nil, key: String, value: String) {
      self.init(unsafeResultMap: ["__typename": "Attribute", "displayType": displayType, "traitType": traitType, "key": key, "value": value])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The display type
    public var displayType: String? {
      get {
        return resultMap["displayType"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "displayType")
      }
    }

    /// The trait type - can be anything its the name it will render so include spaces
    public var traitType: String? {
      get {
        return resultMap["traitType"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "traitType")
      }
    }

    /// identifier of this attribute, we will update by this id
    public var key: String {
      get {
        return resultMap["key"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "key")
      }
    }

    /// Value attribute
    public var value: String {
      get {
        return resultMap["value"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "value")
      }
    }
  }

  public struct Picture: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["NftImage", "MediaSet"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["NftImage": AsNftImage.selections, "MediaSet": AsMediaSet.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeNftImage(contractAddress: String, tokenId: String, uri: String, verified: Bool) -> Picture {
      return Picture(unsafeResultMap: ["__typename": "NftImage", "contractAddress": contractAddress, "tokenId": tokenId, "uri": uri, "verified": verified])
    }

    public static func makeMediaSet(original: AsMediaSet.Original, small: AsMediaSet.Small? = nil, medium: AsMediaSet.Medium? = nil) -> Picture {
      return Picture(unsafeResultMap: ["__typename": "MediaSet", "original": original.resultMap, "small": small.flatMap { (value: AsMediaSet.Small) -> ResultMap in value.resultMap }, "medium": medium.flatMap { (value: AsMediaSet.Medium) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asNftImage: AsNftImage? {
      get {
        if !AsNftImage.possibleTypes.contains(__typename) { return nil }
        return AsNftImage(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsNftImage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["NftImage"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("contractAddress", type: .nonNull(.scalar(String.self))),
          GraphQLField("tokenId", type: .nonNull(.scalar(String.self))),
          GraphQLField("uri", type: .nonNull(.scalar(String.self))),
          GraphQLField("verified", type: .nonNull(.scalar(Bool.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(contractAddress: String, tokenId: String, uri: String, verified: Bool) {
        self.init(unsafeResultMap: ["__typename": "NftImage", "contractAddress": contractAddress, "tokenId": tokenId, "uri": uri, "verified": verified])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The contract address
      public var contractAddress: String {
        get {
          return resultMap["contractAddress"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "contractAddress")
        }
      }

      /// The token id of the nft
      public var tokenId: String {
        get {
          return resultMap["tokenId"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "tokenId")
        }
      }

      /// The token image nft
      public var uri: String {
        get {
          return resultMap["uri"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "uri")
        }
      }

      /// If the NFT is verified
      public var verified: Bool {
        get {
          return resultMap["verified"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "verified")
        }
      }
    }

    public var asMediaSet: AsMediaSet? {
      get {
        if !AsMediaSet.possibleTypes.contains(__typename) { return nil }
        return AsMediaSet(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMediaSet: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MediaSet"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("original", type: .nonNull(.object(Original.selections))),
          GraphQLField("small", type: .object(Small.selections)),
          GraphQLField("medium", type: .object(Medium.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(original: Original, small: Small? = nil, medium: Medium? = nil) {
        self.init(unsafeResultMap: ["__typename": "MediaSet", "original": original.resultMap, "small": small.flatMap { (value: Small) -> ResultMap in value.resultMap }, "medium": medium.flatMap { (value: Medium) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Original media
      public var original: Original {
        get {
          return Original(unsafeResultMap: resultMap["original"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "original")
        }
      }

      /// Small media - will always be null on the public API
      @available(*, deprecated, message: "should not be used will always be null")
      public var small: Small? {
        get {
          return (resultMap["small"] as? ResultMap).flatMap { Small(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "small")
        }
      }

      /// Medium media - will always be null on the public API
      @available(*, deprecated, message: "should not be used will always be null")
      public var medium: Medium? {
        get {
          return (resultMap["medium"] as? ResultMap).flatMap { Medium(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "medium")
        }
      }

      public struct Original: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Small: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Medium: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public struct CoverPicture: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["NftImage", "MediaSet"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["NftImage": AsNftImage.selections, "MediaSet": AsMediaSet.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeNftImage(contractAddress: String, tokenId: String, uri: String, verified: Bool) -> CoverPicture {
      return CoverPicture(unsafeResultMap: ["__typename": "NftImage", "contractAddress": contractAddress, "tokenId": tokenId, "uri": uri, "verified": verified])
    }

    public static func makeMediaSet(original: AsMediaSet.Original, small: AsMediaSet.Small? = nil, medium: AsMediaSet.Medium? = nil) -> CoverPicture {
      return CoverPicture(unsafeResultMap: ["__typename": "MediaSet", "original": original.resultMap, "small": small.flatMap { (value: AsMediaSet.Small) -> ResultMap in value.resultMap }, "medium": medium.flatMap { (value: AsMediaSet.Medium) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asNftImage: AsNftImage? {
      get {
        if !AsNftImage.possibleTypes.contains(__typename) { return nil }
        return AsNftImage(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsNftImage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["NftImage"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("contractAddress", type: .nonNull(.scalar(String.self))),
          GraphQLField("tokenId", type: .nonNull(.scalar(String.self))),
          GraphQLField("uri", type: .nonNull(.scalar(String.self))),
          GraphQLField("verified", type: .nonNull(.scalar(Bool.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(contractAddress: String, tokenId: String, uri: String, verified: Bool) {
        self.init(unsafeResultMap: ["__typename": "NftImage", "contractAddress": contractAddress, "tokenId": tokenId, "uri": uri, "verified": verified])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The contract address
      public var contractAddress: String {
        get {
          return resultMap["contractAddress"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "contractAddress")
        }
      }

      /// The token id of the nft
      public var tokenId: String {
        get {
          return resultMap["tokenId"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "tokenId")
        }
      }

      /// The token image nft
      public var uri: String {
        get {
          return resultMap["uri"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "uri")
        }
      }

      /// If the NFT is verified
      public var verified: Bool {
        get {
          return resultMap["verified"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "verified")
        }
      }
    }

    public var asMediaSet: AsMediaSet? {
      get {
        if !AsMediaSet.possibleTypes.contains(__typename) { return nil }
        return AsMediaSet(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMediaSet: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MediaSet"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("original", type: .nonNull(.object(Original.selections))),
          GraphQLField("small", type: .object(Small.selections)),
          GraphQLField("medium", type: .object(Medium.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(original: Original, small: Small? = nil, medium: Medium? = nil) {
        self.init(unsafeResultMap: ["__typename": "MediaSet", "original": original.resultMap, "small": small.flatMap { (value: Small) -> ResultMap in value.resultMap }, "medium": medium.flatMap { (value: Medium) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Original media
      public var original: Original {
        get {
          return Original(unsafeResultMap: resultMap["original"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "original")
        }
      }

      /// Small media - will always be null on the public API
      @available(*, deprecated, message: "should not be used will always be null")
      public var small: Small? {
        get {
          return (resultMap["small"] as? ResultMap).flatMap { Small(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "small")
        }
      }

      /// Medium media - will always be null on the public API
      @available(*, deprecated, message: "should not be used will always be null")
      public var medium: Medium? {
        get {
          return (resultMap["medium"] as? ResultMap).flatMap { Medium(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "medium")
        }
      }

      public struct Original: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Small: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }

      public struct Medium: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Media"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(MediaFields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var mediaFields: MediaFields {
            get {
              return MediaFields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public struct Dispatcher: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Dispatcher"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("address", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(address: String) {
      self.init(unsafeResultMap: ["__typename": "Dispatcher", "address": address])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The dispatcher address
    public var address: String {
      get {
        return resultMap["address"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "address")
      }
    }
  }

  public struct Stat: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["ProfileStats"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("totalFollowers", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalFollowing", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalPosts", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalComments", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalMirrors", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalPublications", type: .nonNull(.scalar(Int.self))),
        GraphQLField("totalCollects", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(totalFollowers: Int, totalFollowing: Int, totalPosts: Int, totalComments: Int, totalMirrors: Int, totalPublications: Int, totalCollects: Int) {
      self.init(unsafeResultMap: ["__typename": "ProfileStats", "totalFollowers": totalFollowers, "totalFollowing": totalFollowing, "totalPosts": totalPosts, "totalComments": totalComments, "totalMirrors": totalMirrors, "totalPublications": totalPublications, "totalCollects": totalCollects])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Total follower count
    public var totalFollowers: Int {
      get {
        return resultMap["totalFollowers"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalFollowers")
      }
    }

    /// Total following count (remember the wallet follows not profile so will be same for every profile they own)
    public var totalFollowing: Int {
      get {
        return resultMap["totalFollowing"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalFollowing")
      }
    }

    /// Total post count
    public var totalPosts: Int {
      get {
        return resultMap["totalPosts"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalPosts")
      }
    }

    /// Total comment count
    public var totalComments: Int {
      get {
        return resultMap["totalComments"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalComments")
      }
    }

    /// Total mirror count
    public var totalMirrors: Int {
      get {
        return resultMap["totalMirrors"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalMirrors")
      }
    }

    /// Total publication count
    public var totalPublications: Int {
      get {
        return resultMap["totalPublications"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalPublications")
      }
    }

    /// Total collects count
    public var totalCollects: Int {
      get {
        return resultMap["totalCollects"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "totalCollects")
      }
    }
  }

  public struct FollowModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FeeFollowModuleSettings", "ProfileFollowModuleSettings", "RevertFollowModuleSettings", "UnknownFollowModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["FeeFollowModuleSettings": AsFeeFollowModuleSettings.selections, "ProfileFollowModuleSettings": AsProfileFollowModuleSettings.selections, "RevertFollowModuleSettings": AsRevertFollowModuleSettings.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeUnknownFollowModuleSettings() -> FollowModule {
      return FollowModule(unsafeResultMap: ["__typename": "UnknownFollowModuleSettings"])
    }

    public static func makeFeeFollowModuleSettings(type: FollowModules, amount: AsFeeFollowModuleSettings.Amount, recipient: String) -> FollowModule {
      return FollowModule(unsafeResultMap: ["__typename": "FeeFollowModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient])
    }

    public static func makeProfileFollowModuleSettings(type: FollowModules) -> FollowModule {
      return FollowModule(unsafeResultMap: ["__typename": "ProfileFollowModuleSettings", "type": type])
    }

    public static func makeRevertFollowModuleSettings(type: FollowModules) -> FollowModule {
      return FollowModule(unsafeResultMap: ["__typename": "RevertFollowModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asFeeFollowModuleSettings: AsFeeFollowModuleSettings? {
      get {
        if !AsFeeFollowModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsFeeFollowModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsFeeFollowModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["FeeFollowModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(FollowModules.self))),
          GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
          GraphQLField("recipient", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: FollowModules, amount: Amount, recipient: String) {
        self.init(unsafeResultMap: ["__typename": "FeeFollowModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The follow modules enum
      public var type: FollowModules {
        get {
          return resultMap["type"]! as! FollowModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      /// The collect module amount info
      public var amount: Amount {
        get {
          return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "amount")
        }
      }

      /// The collect module recipient address
      public var recipient: String {
        get {
          return resultMap["recipient"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "recipient")
        }
      }

      public struct Amount: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ModuleFeeAmount"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("asset", type: .nonNull(.object(Asset.selections))),
            GraphQLField("value", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(asset: Asset, value: String) {
          self.init(unsafeResultMap: ["__typename": "ModuleFeeAmount", "asset": asset.resultMap, "value": value])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The erc20 token info
        public var asset: Asset {
          get {
            return Asset(unsafeResultMap: resultMap["asset"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "asset")
          }
        }

        /// Floating point number as string (e.g. 42.009837). It could have the entire precision of the Asset or be truncated to the last significant decimal.
        public var value: String {
          get {
            return resultMap["value"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "value")
          }
        }

        public struct Asset: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Erc20"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("name", type: .nonNull(.scalar(String.self))),
              GraphQLField("symbol", type: .nonNull(.scalar(String.self))),
              GraphQLField("decimals", type: .nonNull(.scalar(Int.self))),
              GraphQLField("address", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(name: String, symbol: String, decimals: Int, address: String) {
            self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Name of the symbol
          public var name: String {
            get {
              return resultMap["name"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "name")
            }
          }

          /// Symbol for the token
          public var symbol: String {
            get {
              return resultMap["symbol"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "symbol")
            }
          }

          /// Decimal places for the token
          public var decimals: Int {
            get {
              return resultMap["decimals"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "decimals")
            }
          }

          /// The erc20 address
          public var address: String {
            get {
              return resultMap["address"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "address")
            }
          }
        }
      }
    }

    public var asProfileFollowModuleSettings: AsProfileFollowModuleSettings? {
      get {
        if !AsProfileFollowModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsProfileFollowModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsProfileFollowModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ProfileFollowModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(FollowModules.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: FollowModules) {
        self.init(unsafeResultMap: ["__typename": "ProfileFollowModuleSettings", "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The follow module enum
      public var type: FollowModules {
        get {
          return resultMap["type"]! as! FollowModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }

    public var asRevertFollowModuleSettings: AsRevertFollowModuleSettings? {
      get {
        if !AsRevertFollowModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsRevertFollowModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsRevertFollowModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["RevertFollowModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(FollowModules.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: FollowModules) {
        self.init(unsafeResultMap: ["__typename": "RevertFollowModuleSettings", "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The follow module enum
      public var type: FollowModules {
        get {
          return resultMap["type"]! as! FollowModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }
  }
}

public struct PublicationStatsFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PublicationStatsFields on PublicationStats {
      __typename
      totalAmountOfMirrors
      totalAmountOfCollects
      totalAmountOfComments
    }
    """

  public static let possibleTypes: [String] = ["PublicationStats"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("totalAmountOfMirrors", type: .nonNull(.scalar(Int.self))),
      GraphQLField("totalAmountOfCollects", type: .nonNull(.scalar(Int.self))),
      GraphQLField("totalAmountOfComments", type: .nonNull(.scalar(Int.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(totalAmountOfMirrors: Int, totalAmountOfCollects: Int, totalAmountOfComments: Int) {
    self.init(unsafeResultMap: ["__typename": "PublicationStats", "totalAmountOfMirrors": totalAmountOfMirrors, "totalAmountOfCollects": totalAmountOfCollects, "totalAmountOfComments": totalAmountOfComments])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The total amount of mirrors
  public var totalAmountOfMirrors: Int {
    get {
      return resultMap["totalAmountOfMirrors"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "totalAmountOfMirrors")
    }
  }

  /// The total amount of collects
  public var totalAmountOfCollects: Int {
    get {
      return resultMap["totalAmountOfCollects"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "totalAmountOfCollects")
    }
  }

  /// The total amount of comments
  public var totalAmountOfComments: Int {
    get {
      return resultMap["totalAmountOfComments"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "totalAmountOfComments")
    }
  }
}

public struct MetadataOutputFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MetadataOutputFields on MetadataOutput {
      __typename
      name
      description
      content
      media {
        __typename
        original {
          __typename
          ...MediaFields
        }
        small {
          __typename
          ...MediaFields
        }
        medium {
          __typename
          ...MediaFields
        }
      }
      attributes {
        __typename
        displayType
        traitType
        value
      }
    }
    """

  public static let possibleTypes: [String] = ["MetadataOutput"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .scalar(String.self)),
      GraphQLField("description", type: .scalar(String.self)),
      GraphQLField("content", type: .scalar(String.self)),
      GraphQLField("media", type: .nonNull(.list(.nonNull(.object(Medium.selections))))),
      GraphQLField("attributes", type: .nonNull(.list(.nonNull(.object(Attribute.selections))))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String? = nil, description: String? = nil, content: String? = nil, media: [Medium], attributes: [Attribute]) {
    self.init(unsafeResultMap: ["__typename": "MetadataOutput", "name": name, "description": description, "content": content, "media": media.map { (value: Medium) -> ResultMap in value.resultMap }, "attributes": attributes.map { (value: Attribute) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The metadata name
  public var name: String? {
    get {
      return resultMap["name"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// This is the metadata description
  public var description: String? {
    get {
      return resultMap["description"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "description")
    }
  }

  /// This is the metadata content for the publication, should be markdown
  public var content: String? {
    get {
      return resultMap["content"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }

  /// The images/audios/videos for the publication
  public var media: [Medium] {
    get {
      return (resultMap["media"] as! [ResultMap]).map { (value: ResultMap) -> Medium in Medium(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Medium) -> ResultMap in value.resultMap }, forKey: "media")
    }
  }

  /// The attributes
  public var attributes: [Attribute] {
    get {
      return (resultMap["attributes"] as! [ResultMap]).map { (value: ResultMap) -> Attribute in Attribute(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Attribute) -> ResultMap in value.resultMap }, forKey: "attributes")
    }
  }

  public struct Medium: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MediaSet"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("original", type: .nonNull(.object(Original.selections))),
        GraphQLField("small", type: .object(Small.selections)),
        GraphQLField("medium", type: .object(Medium.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(original: Original, small: Small? = nil, medium: Medium? = nil) {
      self.init(unsafeResultMap: ["__typename": "MediaSet", "original": original.resultMap, "small": small.flatMap { (value: Small) -> ResultMap in value.resultMap }, "medium": medium.flatMap { (value: Medium) -> ResultMap in value.resultMap }])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Original media
    public var original: Original {
      get {
        return Original(unsafeResultMap: resultMap["original"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "original")
      }
    }

    /// Small media - will always be null on the public API
    @available(*, deprecated, message: "should not be used will always be null")
    public var small: Small? {
      get {
        return (resultMap["small"] as? ResultMap).flatMap { Small(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "small")
      }
    }

    /// Medium media - will always be null on the public API
    @available(*, deprecated, message: "should not be used will always be null")
    public var medium: Medium? {
      get {
        return (resultMap["medium"] as? ResultMap).flatMap { Medium(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "medium")
      }
    }

    public struct Original: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Media"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MediaFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var mediaFields: MediaFields {
          get {
            return MediaFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Small: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Media"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MediaFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var mediaFields: MediaFields {
          get {
            return MediaFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public struct Medium: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Media"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MediaFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String, width: Int? = nil, height: Int? = nil, mimeType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "Media", "url": url, "width": width, "height": height, "mimeType": mimeType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var mediaFields: MediaFields {
          get {
            return MediaFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct Attribute: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MetadataAttributeOutput"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("displayType", type: .scalar(PublicationMetadataDisplayTypes.self)),
        GraphQLField("traitType", type: .scalar(String.self)),
        GraphQLField("value", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(displayType: PublicationMetadataDisplayTypes? = nil, traitType: String? = nil, value: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "MetadataAttributeOutput", "displayType": displayType, "traitType": traitType, "value": value])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The display type
    public var displayType: PublicationMetadataDisplayTypes? {
      get {
        return resultMap["displayType"] as? PublicationMetadataDisplayTypes
      }
      set {
        resultMap.updateValue(newValue, forKey: "displayType")
      }
    }

    /// The trait type - can be anything its the name it will render so include spaces
    public var traitType: String? {
      get {
        return resultMap["traitType"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "traitType")
      }
    }

    /// The value
    public var value: String? {
      get {
        return resultMap["value"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "value")
      }
    }
  }
}

public struct Erc20Fields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment Erc20Fields on Erc20 {
      __typename
      name
      symbol
      decimals
      address
    }
    """

  public static let possibleTypes: [String] = ["Erc20"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("name", type: .nonNull(.scalar(String.self))),
      GraphQLField("symbol", type: .nonNull(.scalar(String.self))),
      GraphQLField("decimals", type: .nonNull(.scalar(Int.self))),
      GraphQLField("address", type: .nonNull(.scalar(String.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(name: String, symbol: String, decimals: Int, address: String) {
    self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Name of the symbol
  public var name: String {
    get {
      return resultMap["name"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "name")
    }
  }

  /// Symbol for the token
  public var symbol: String {
    get {
      return resultMap["symbol"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "symbol")
    }
  }

  /// Decimal places for the token
  public var decimals: Int {
    get {
      return resultMap["decimals"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "decimals")
    }
  }

  /// The erc20 address
  public var address: String {
    get {
      return resultMap["address"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "address")
    }
  }
}

public struct CollectModuleFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CollectModuleFields on CollectModule {
      __typename
      ... on FreeCollectModuleSettings {
        __typename
        type
      }
      ... on FeeCollectModuleSettings {
        __typename
        type
        amount {
          __typename
          asset {
            __typename
            ...Erc20Fields
          }
          value
        }
        recipient
        referralFee
      }
      ... on LimitedFeeCollectModuleSettings {
        __typename
        type
        collectLimit
        amount {
          __typename
          asset {
            __typename
            ...Erc20Fields
          }
          value
        }
        recipient
        referralFee
      }
      ... on LimitedTimedFeeCollectModuleSettings {
        __typename
        type
        collectLimit
        amount {
          __typename
          asset {
            __typename
            ...Erc20Fields
          }
          value
        }
        recipient
        referralFee
        endTimestamp
      }
      ... on RevertCollectModuleSettings {
        __typename
        type
      }
      ... on TimedFeeCollectModuleSettings {
        __typename
        type
        amount {
          __typename
          asset {
            __typename
            ...Erc20Fields
          }
          value
        }
        recipient
        referralFee
        endTimestamp
      }
    }
    """

  public static let possibleTypes: [String] = ["FreeCollectModuleSettings", "FeeCollectModuleSettings", "LimitedFeeCollectModuleSettings", "LimitedTimedFeeCollectModuleSettings", "RevertCollectModuleSettings", "TimedFeeCollectModuleSettings", "UnknownCollectModuleSettings"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLTypeCase(
        variants: ["FreeCollectModuleSettings": AsFreeCollectModuleSettings.selections, "FeeCollectModuleSettings": AsFeeCollectModuleSettings.selections, "LimitedFeeCollectModuleSettings": AsLimitedFeeCollectModuleSettings.selections, "LimitedTimedFeeCollectModuleSettings": AsLimitedTimedFeeCollectModuleSettings.selections, "RevertCollectModuleSettings": AsRevertCollectModuleSettings.selections, "TimedFeeCollectModuleSettings": AsTimedFeeCollectModuleSettings.selections],
        default: [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        ]
      )
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public static func makeUnknownCollectModuleSettings() -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "UnknownCollectModuleSettings"])
  }

  public static func makeFreeCollectModuleSettings(type: CollectModules) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "FreeCollectModuleSettings", "type": type])
  }

  public static func makeFeeCollectModuleSettings(type: CollectModules, amount: AsFeeCollectModuleSettings.Amount, recipient: String, referralFee: Double) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "FeeCollectModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee])
  }

  public static func makeLimitedFeeCollectModuleSettings(type: CollectModules, collectLimit: String, amount: AsLimitedFeeCollectModuleSettings.Amount, recipient: String, referralFee: Double) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "LimitedFeeCollectModuleSettings", "type": type, "collectLimit": collectLimit, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee])
  }

  public static func makeLimitedTimedFeeCollectModuleSettings(type: CollectModules, collectLimit: String, amount: AsLimitedTimedFeeCollectModuleSettings.Amount, recipient: String, referralFee: Double, endTimestamp: String) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "LimitedTimedFeeCollectModuleSettings", "type": type, "collectLimit": collectLimit, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee, "endTimestamp": endTimestamp])
  }

  public static func makeRevertCollectModuleSettings(type: CollectModules) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "RevertCollectModuleSettings", "type": type])
  }

  public static func makeTimedFeeCollectModuleSettings(type: CollectModules, amount: AsTimedFeeCollectModuleSettings.Amount, recipient: String, referralFee: Double, endTimestamp: String) -> CollectModuleFields {
    return CollectModuleFields(unsafeResultMap: ["__typename": "TimedFeeCollectModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee, "endTimestamp": endTimestamp])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var asFreeCollectModuleSettings: AsFreeCollectModuleSettings? {
    get {
      if !AsFreeCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsFreeCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsFreeCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FreeCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules) {
      self.init(unsafeResultMap: ["__typename": "FreeCollectModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }
  }

  public var asFeeCollectModuleSettings: AsFeeCollectModuleSettings? {
    get {
      if !AsFeeCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsFeeCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsFeeCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FeeCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("recipient", type: .nonNull(.scalar(String.self))),
        GraphQLField("referralFee", type: .nonNull(.scalar(Double.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules, amount: Amount, recipient: String, referralFee: Double) {
      self.init(unsafeResultMap: ["__typename": "FeeCollectModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }

    /// The collect module amount info
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// The collect module recipient address
    public var recipient: String {
      get {
        return resultMap["recipient"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "recipient")
      }
    }

    /// The collect module referral fee
    public var referralFee: Double {
      get {
        return resultMap["referralFee"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "referralFee")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ModuleFeeAmount"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("asset", type: .nonNull(.object(Asset.selections))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(asset: Asset, value: String) {
        self.init(unsafeResultMap: ["__typename": "ModuleFeeAmount", "asset": asset.resultMap, "value": value])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The erc20 token info
      public var asset: Asset {
        get {
          return Asset(unsafeResultMap: resultMap["asset"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "asset")
        }
      }

      /// Floating point number as string (e.g. 42.009837). It could have the entire precision of the Asset or be truncated to the last significant decimal.
      public var value: String {
        get {
          return resultMap["value"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "value")
        }
      }

      public struct Asset: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Erc20"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(Erc20Fields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, symbol: String, decimals: Int, address: String) {
          self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var erc20Fields: Erc20Fields {
            get {
              return Erc20Fields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public var asLimitedFeeCollectModuleSettings: AsLimitedFeeCollectModuleSettings? {
    get {
      if !AsLimitedFeeCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsLimitedFeeCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsLimitedFeeCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["LimitedFeeCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
        GraphQLField("collectLimit", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("recipient", type: .nonNull(.scalar(String.self))),
        GraphQLField("referralFee", type: .nonNull(.scalar(Double.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules, collectLimit: String, amount: Amount, recipient: String, referralFee: Double) {
      self.init(unsafeResultMap: ["__typename": "LimitedFeeCollectModuleSettings", "type": type, "collectLimit": collectLimit, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }

    /// The collect module limit
    public var collectLimit: String {
      get {
        return resultMap["collectLimit"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "collectLimit")
      }
    }

    /// The collect module amount info
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// The collect module recipient address
    public var recipient: String {
      get {
        return resultMap["recipient"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "recipient")
      }
    }

    /// The collect module referral fee
    public var referralFee: Double {
      get {
        return resultMap["referralFee"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "referralFee")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ModuleFeeAmount"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("asset", type: .nonNull(.object(Asset.selections))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(asset: Asset, value: String) {
        self.init(unsafeResultMap: ["__typename": "ModuleFeeAmount", "asset": asset.resultMap, "value": value])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The erc20 token info
      public var asset: Asset {
        get {
          return Asset(unsafeResultMap: resultMap["asset"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "asset")
        }
      }

      /// Floating point number as string (e.g. 42.009837). It could have the entire precision of the Asset or be truncated to the last significant decimal.
      public var value: String {
        get {
          return resultMap["value"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "value")
        }
      }

      public struct Asset: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Erc20"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(Erc20Fields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, symbol: String, decimals: Int, address: String) {
          self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var erc20Fields: Erc20Fields {
            get {
              return Erc20Fields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public var asLimitedTimedFeeCollectModuleSettings: AsLimitedTimedFeeCollectModuleSettings? {
    get {
      if !AsLimitedTimedFeeCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsLimitedTimedFeeCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsLimitedTimedFeeCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["LimitedTimedFeeCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
        GraphQLField("collectLimit", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("recipient", type: .nonNull(.scalar(String.self))),
        GraphQLField("referralFee", type: .nonNull(.scalar(Double.self))),
        GraphQLField("endTimestamp", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules, collectLimit: String, amount: Amount, recipient: String, referralFee: Double, endTimestamp: String) {
      self.init(unsafeResultMap: ["__typename": "LimitedTimedFeeCollectModuleSettings", "type": type, "collectLimit": collectLimit, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee, "endTimestamp": endTimestamp])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }

    /// The collect module limit
    public var collectLimit: String {
      get {
        return resultMap["collectLimit"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "collectLimit")
      }
    }

    /// The collect module amount info
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// The collect module recipient address
    public var recipient: String {
      get {
        return resultMap["recipient"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "recipient")
      }
    }

    /// The collect module referral fee
    public var referralFee: Double {
      get {
        return resultMap["referralFee"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "referralFee")
      }
    }

    /// The collect module end timestamp
    public var endTimestamp: String {
      get {
        return resultMap["endTimestamp"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "endTimestamp")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ModuleFeeAmount"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("asset", type: .nonNull(.object(Asset.selections))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(asset: Asset, value: String) {
        self.init(unsafeResultMap: ["__typename": "ModuleFeeAmount", "asset": asset.resultMap, "value": value])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The erc20 token info
      public var asset: Asset {
        get {
          return Asset(unsafeResultMap: resultMap["asset"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "asset")
        }
      }

      /// Floating point number as string (e.g. 42.009837). It could have the entire precision of the Asset or be truncated to the last significant decimal.
      public var value: String {
        get {
          return resultMap["value"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "value")
        }
      }

      public struct Asset: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Erc20"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(Erc20Fields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, symbol: String, decimals: Int, address: String) {
          self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var erc20Fields: Erc20Fields {
            get {
              return Erc20Fields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public var asRevertCollectModuleSettings: AsRevertCollectModuleSettings? {
    get {
      if !AsRevertCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsRevertCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsRevertCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RevertCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules) {
      self.init(unsafeResultMap: ["__typename": "RevertCollectModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }
  }

  public var asTimedFeeCollectModuleSettings: AsTimedFeeCollectModuleSettings? {
    get {
      if !AsTimedFeeCollectModuleSettings.possibleTypes.contains(__typename) { return nil }
      return AsTimedFeeCollectModuleSettings(unsafeResultMap: resultMap)
    }
    set {
      guard let newValue = newValue else { return }
      resultMap = newValue.resultMap
    }
  }

  public struct AsTimedFeeCollectModuleSettings: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["TimedFeeCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(CollectModules.self))),
        GraphQLField("amount", type: .nonNull(.object(Amount.selections))),
        GraphQLField("recipient", type: .nonNull(.scalar(String.self))),
        GraphQLField("referralFee", type: .nonNull(.scalar(Double.self))),
        GraphQLField("endTimestamp", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(type: CollectModules, amount: Amount, recipient: String, referralFee: Double, endTimestamp: String) {
      self.init(unsafeResultMap: ["__typename": "TimedFeeCollectModuleSettings", "type": type, "amount": amount.resultMap, "recipient": recipient, "referralFee": referralFee, "endTimestamp": endTimestamp])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The collect modules enum
    public var type: CollectModules {
      get {
        return resultMap["type"]! as! CollectModules
      }
      set {
        resultMap.updateValue(newValue, forKey: "type")
      }
    }

    /// The collect module amount info
    public var amount: Amount {
      get {
        return Amount(unsafeResultMap: resultMap["amount"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "amount")
      }
    }

    /// The collect module recipient address
    public var recipient: String {
      get {
        return resultMap["recipient"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "recipient")
      }
    }

    /// The collect module referral fee
    public var referralFee: Double {
      get {
        return resultMap["referralFee"]! as! Double
      }
      set {
        resultMap.updateValue(newValue, forKey: "referralFee")
      }
    }

    /// The collect module end timestamp
    public var endTimestamp: String {
      get {
        return resultMap["endTimestamp"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "endTimestamp")
      }
    }

    public struct Amount: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["ModuleFeeAmount"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("asset", type: .nonNull(.object(Asset.selections))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(asset: Asset, value: String) {
        self.init(unsafeResultMap: ["__typename": "ModuleFeeAmount", "asset": asset.resultMap, "value": value])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The erc20 token info
      public var asset: Asset {
        get {
          return Asset(unsafeResultMap: resultMap["asset"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "asset")
        }
      }

      /// Floating point number as string (e.g. 42.009837). It could have the entire precision of the Asset or be truncated to the last significant decimal.
      public var value: String {
        get {
          return resultMap["value"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "value")
        }
      }

      public struct Asset: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Erc20"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(Erc20Fields.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, symbol: String, decimals: Int, address: String) {
          self.init(unsafeResultMap: ["__typename": "Erc20", "name": name, "symbol": symbol, "decimals": decimals, "address": address])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var erc20Fields: Erc20Fields {
            get {
              return Erc20Fields(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }
}

public struct PostFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PostFields on Post {
      __typename
      id
      profile {
        __typename
        ...ProfileFields
      }
      stats {
        __typename
        ...PublicationStatsFields
      }
      metadata {
        __typename
        ...MetadataOutputFields
      }
      createdAt
      collectModule {
        __typename
        ...CollectModuleFields
      }
      referenceModule {
        __typename
        ... on FollowOnlyReferenceModuleSettings {
          __typename
          type
        }
      }
      appId
      hidden
      reaction(request: null)
      mirrors(by: null)
      hasCollectedByMe
    }
    """

  public static let possibleTypes: [String] = ["Post"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
      GraphQLField("stats", type: .nonNull(.object(Stat.selections))),
      GraphQLField("metadata", type: .nonNull(.object(Metadatum.selections))),
      GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
      GraphQLField("collectModule", type: .nonNull(.object(CollectModule.selections))),
      GraphQLField("referenceModule", type: .object(ReferenceModule.selections)),
      GraphQLField("appId", type: .scalar(String.self)),
      GraphQLField("hidden", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("reaction", arguments: ["request": nil], type: .scalar(ReactionTypes.self)),
      GraphQLField("mirrors", arguments: ["by": nil], type: .nonNull(.list(.nonNull(.scalar(String.self))))),
      GraphQLField("hasCollectedByMe", type: .nonNull(.scalar(Bool.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, profile: Profile, stats: Stat, metadata: Metadatum, createdAt: String, collectModule: CollectModule, referenceModule: ReferenceModule? = nil, appId: String? = nil, hidden: Bool, reaction: ReactionTypes? = nil, mirrors: [String], hasCollectedByMe: Bool) {
    self.init(unsafeResultMap: ["__typename": "Post", "id": id, "profile": profile.resultMap, "stats": stats.resultMap, "metadata": metadata.resultMap, "createdAt": createdAt, "collectModule": collectModule.resultMap, "referenceModule": referenceModule.flatMap { (value: ReferenceModule) -> ResultMap in value.resultMap }, "appId": appId, "hidden": hidden, "reaction": reaction, "mirrors": mirrors, "hasCollectedByMe": hasCollectedByMe])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The internal publication id
  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The profile ref
  public var profile: Profile {
    get {
      return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "profile")
    }
  }

  /// The publication stats
  public var stats: Stat {
    get {
      return Stat(unsafeResultMap: resultMap["stats"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "stats")
    }
  }

  /// The metadata for the post
  public var metadata: Metadatum {
    get {
      return Metadatum(unsafeResultMap: resultMap["metadata"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "metadata")
    }
  }

  /// The date the post was created on
  public var createdAt: String {
    get {
      return resultMap["createdAt"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  /// The collect module
  public var collectModule: CollectModule {
    get {
      return CollectModule(unsafeResultMap: resultMap["collectModule"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "collectModule")
    }
  }

  /// The reference module
  public var referenceModule: ReferenceModule? {
    get {
      return (resultMap["referenceModule"] as? ResultMap).flatMap { ReferenceModule(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "referenceModule")
    }
  }

  /// ID of the source
  public var appId: String? {
    get {
      return resultMap["appId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "appId")
    }
  }

  /// If the publication has been hidden if it has then the content and media is not available
  public var hidden: Bool {
    get {
      return resultMap["hidden"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hidden")
    }
  }

  public var reaction: ReactionTypes? {
    get {
      return resultMap["reaction"] as? ReactionTypes
    }
    set {
      resultMap.updateValue(newValue, forKey: "reaction")
    }
  }

  public var mirrors: [String] {
    get {
      return resultMap["mirrors"]! as! [String]
    }
    set {
      resultMap.updateValue(newValue, forKey: "mirrors")
    }
  }

  public var hasCollectedByMe: Bool {
    get {
      return resultMap["hasCollectedByMe"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasCollectedByMe")
    }
  }

  public struct Profile: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Profile"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ProfileFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var profileFields: ProfileFields {
        get {
          return ProfileFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Stat: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PublicationStats"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(PublicationStatsFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(totalAmountOfMirrors: Int, totalAmountOfCollects: Int, totalAmountOfComments: Int) {
      self.init(unsafeResultMap: ["__typename": "PublicationStats", "totalAmountOfMirrors": totalAmountOfMirrors, "totalAmountOfCollects": totalAmountOfCollects, "totalAmountOfComments": totalAmountOfComments])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var publicationStatsFields: PublicationStatsFields {
        get {
          return PublicationStatsFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Metadatum: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MetadataOutput"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(MetadataOutputFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var metadataOutputFields: MetadataOutputFields {
        get {
          return MetadataOutputFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct CollectModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FreeCollectModuleSettings", "FeeCollectModuleSettings", "LimitedFeeCollectModuleSettings", "LimitedTimedFeeCollectModuleSettings", "RevertCollectModuleSettings", "TimedFeeCollectModuleSettings", "UnknownCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CollectModuleFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeFreeCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "FreeCollectModuleSettings", "type": type])
    }

    public static func makeRevertCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "RevertCollectModuleSettings", "type": type])
    }

    public static func makeUnknownCollectModuleSettings() -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "UnknownCollectModuleSettings"])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var collectModuleFields: CollectModuleFields {
        get {
          return CollectModuleFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct ReferenceModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings", "UnknownReferenceModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["FollowOnlyReferenceModuleSettings": AsFollowOnlyReferenceModuleSettings.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeUnknownReferenceModuleSettings() -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "UnknownReferenceModuleSettings"])
    }

    public static func makeFollowOnlyReferenceModuleSettings(type: ReferenceModules) -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asFollowOnlyReferenceModuleSettings: AsFollowOnlyReferenceModuleSettings? {
      get {
        if !AsFollowOnlyReferenceModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsFollowOnlyReferenceModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsFollowOnlyReferenceModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(ReferenceModules.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: ReferenceModules) {
        self.init(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The reference modules enum
      public var type: ReferenceModules {
        get {
          return resultMap["type"]! as! ReferenceModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }
  }
}

public struct MirrorBaseFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MirrorBaseFields on Mirror {
      __typename
      id
      profile {
        __typename
        ...ProfileFields
      }
      stats {
        __typename
        ...PublicationStatsFields
      }
      metadata {
        __typename
        ...MetadataOutputFields
      }
      createdAt
      collectModule {
        __typename
        ...CollectModuleFields
      }
      referenceModule {
        __typename
        ... on FollowOnlyReferenceModuleSettings {
          __typename
          type
        }
      }
      appId
      hidden
      reaction(request: null)
      hasCollectedByMe
    }
    """

  public static let possibleTypes: [String] = ["Mirror"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
      GraphQLField("stats", type: .nonNull(.object(Stat.selections))),
      GraphQLField("metadata", type: .nonNull(.object(Metadatum.selections))),
      GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
      GraphQLField("collectModule", type: .nonNull(.object(CollectModule.selections))),
      GraphQLField("referenceModule", type: .object(ReferenceModule.selections)),
      GraphQLField("appId", type: .scalar(String.self)),
      GraphQLField("hidden", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("reaction", arguments: ["request": nil], type: .scalar(ReactionTypes.self)),
      GraphQLField("hasCollectedByMe", type: .nonNull(.scalar(Bool.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, profile: Profile, stats: Stat, metadata: Metadatum, createdAt: String, collectModule: CollectModule, referenceModule: ReferenceModule? = nil, appId: String? = nil, hidden: Bool, reaction: ReactionTypes? = nil, hasCollectedByMe: Bool) {
    self.init(unsafeResultMap: ["__typename": "Mirror", "id": id, "profile": profile.resultMap, "stats": stats.resultMap, "metadata": metadata.resultMap, "createdAt": createdAt, "collectModule": collectModule.resultMap, "referenceModule": referenceModule.flatMap { (value: ReferenceModule) -> ResultMap in value.resultMap }, "appId": appId, "hidden": hidden, "reaction": reaction, "hasCollectedByMe": hasCollectedByMe])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The internal publication id
  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The profile ref
  public var profile: Profile {
    get {
      return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "profile")
    }
  }

  /// The publication stats
  public var stats: Stat {
    get {
      return Stat(unsafeResultMap: resultMap["stats"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "stats")
    }
  }

  /// The metadata for the post
  public var metadata: Metadatum {
    get {
      return Metadatum(unsafeResultMap: resultMap["metadata"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "metadata")
    }
  }

  /// The date the post was created on
  public var createdAt: String {
    get {
      return resultMap["createdAt"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  /// The collect module
  public var collectModule: CollectModule {
    get {
      return CollectModule(unsafeResultMap: resultMap["collectModule"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "collectModule")
    }
  }

  /// The reference module
  public var referenceModule: ReferenceModule? {
    get {
      return (resultMap["referenceModule"] as? ResultMap).flatMap { ReferenceModule(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "referenceModule")
    }
  }

  /// ID of the source
  public var appId: String? {
    get {
      return resultMap["appId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "appId")
    }
  }

  /// If the publication has been hidden if it has then the content and media is not available
  public var hidden: Bool {
    get {
      return resultMap["hidden"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hidden")
    }
  }

  public var reaction: ReactionTypes? {
    get {
      return resultMap["reaction"] as? ReactionTypes
    }
    set {
      resultMap.updateValue(newValue, forKey: "reaction")
    }
  }

  public var hasCollectedByMe: Bool {
    get {
      return resultMap["hasCollectedByMe"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasCollectedByMe")
    }
  }

  public struct Profile: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Profile"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ProfileFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var profileFields: ProfileFields {
        get {
          return ProfileFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Stat: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PublicationStats"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(PublicationStatsFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(totalAmountOfMirrors: Int, totalAmountOfCollects: Int, totalAmountOfComments: Int) {
      self.init(unsafeResultMap: ["__typename": "PublicationStats", "totalAmountOfMirrors": totalAmountOfMirrors, "totalAmountOfCollects": totalAmountOfCollects, "totalAmountOfComments": totalAmountOfComments])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var publicationStatsFields: PublicationStatsFields {
        get {
          return PublicationStatsFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Metadatum: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MetadataOutput"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(MetadataOutputFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var metadataOutputFields: MetadataOutputFields {
        get {
          return MetadataOutputFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct CollectModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FreeCollectModuleSettings", "FeeCollectModuleSettings", "LimitedFeeCollectModuleSettings", "LimitedTimedFeeCollectModuleSettings", "RevertCollectModuleSettings", "TimedFeeCollectModuleSettings", "UnknownCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CollectModuleFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeFreeCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "FreeCollectModuleSettings", "type": type])
    }

    public static func makeRevertCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "RevertCollectModuleSettings", "type": type])
    }

    public static func makeUnknownCollectModuleSettings() -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "UnknownCollectModuleSettings"])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var collectModuleFields: CollectModuleFields {
        get {
          return CollectModuleFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct ReferenceModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings", "UnknownReferenceModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["FollowOnlyReferenceModuleSettings": AsFollowOnlyReferenceModuleSettings.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeUnknownReferenceModuleSettings() -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "UnknownReferenceModuleSettings"])
    }

    public static func makeFollowOnlyReferenceModuleSettings(type: ReferenceModules) -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asFollowOnlyReferenceModuleSettings: AsFollowOnlyReferenceModuleSettings? {
      get {
        if !AsFollowOnlyReferenceModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsFollowOnlyReferenceModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsFollowOnlyReferenceModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(ReferenceModules.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: ReferenceModules) {
        self.init(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The reference modules enum
      public var type: ReferenceModules {
        get {
          return resultMap["type"]! as! ReferenceModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }
  }
}

public struct MirrorFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MirrorFields on Mirror {
      __typename
      ...MirrorBaseFields
      mirrorOf {
        __typename
        ... on Post {
          __typename
          ...PostFields
        }
        ... on Comment {
          __typename
          ...CommentFields
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Mirror"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(MirrorBaseFields.self),
      GraphQLField("mirrorOf", type: .nonNull(.object(MirrorOf.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The mirror publication
  public var mirrorOf: MirrorOf {
    get {
      return MirrorOf(unsafeResultMap: resultMap["mirrorOf"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "mirrorOf")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var mirrorBaseFields: MirrorBaseFields {
      get {
        return MirrorBaseFields(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public struct MirrorOf: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Post", "Comment"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["Post": AsPost.selections, "Comment": AsComment.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asPost: AsPost? {
      get {
        if !AsPost.possibleTypes.contains(__typename) { return nil }
        return AsPost(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsPost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Post"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(PostFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var postFields: PostFields {
          get {
            return PostFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asComment: AsComment? {
      get {
        if !AsComment.possibleTypes.contains(__typename) { return nil }
        return AsComment(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsComment: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Comment"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(CommentFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var commentFields: CommentFields {
          get {
            return CommentFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public struct CommentBaseFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CommentBaseFields on Comment {
      __typename
      id
      profile {
        __typename
        ...ProfileFields
      }
      stats {
        __typename
        ...PublicationStatsFields
      }
      metadata {
        __typename
        ...MetadataOutputFields
      }
      createdAt
      collectModule {
        __typename
        ...CollectModuleFields
      }
      referenceModule {
        __typename
        ... on FollowOnlyReferenceModuleSettings {
          __typename
          type
        }
      }
      appId
      hidden
      reaction(request: null)
      mirrors(by: null)
      hasCollectedByMe
    }
    """

  public static let possibleTypes: [String] = ["Comment"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("profile", type: .nonNull(.object(Profile.selections))),
      GraphQLField("stats", type: .nonNull(.object(Stat.selections))),
      GraphQLField("metadata", type: .nonNull(.object(Metadatum.selections))),
      GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
      GraphQLField("collectModule", type: .nonNull(.object(CollectModule.selections))),
      GraphQLField("referenceModule", type: .object(ReferenceModule.selections)),
      GraphQLField("appId", type: .scalar(String.self)),
      GraphQLField("hidden", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("reaction", arguments: ["request": nil], type: .scalar(ReactionTypes.self)),
      GraphQLField("mirrors", arguments: ["by": nil], type: .nonNull(.list(.nonNull(.scalar(String.self))))),
      GraphQLField("hasCollectedByMe", type: .nonNull(.scalar(Bool.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, profile: Profile, stats: Stat, metadata: Metadatum, createdAt: String, collectModule: CollectModule, referenceModule: ReferenceModule? = nil, appId: String? = nil, hidden: Bool, reaction: ReactionTypes? = nil, mirrors: [String], hasCollectedByMe: Bool) {
    self.init(unsafeResultMap: ["__typename": "Comment", "id": id, "profile": profile.resultMap, "stats": stats.resultMap, "metadata": metadata.resultMap, "createdAt": createdAt, "collectModule": collectModule.resultMap, "referenceModule": referenceModule.flatMap { (value: ReferenceModule) -> ResultMap in value.resultMap }, "appId": appId, "hidden": hidden, "reaction": reaction, "mirrors": mirrors, "hasCollectedByMe": hasCollectedByMe])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The internal publication id
  public var id: String {
    get {
      return resultMap["id"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  /// The profile ref
  public var profile: Profile {
    get {
      return Profile(unsafeResultMap: resultMap["profile"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "profile")
    }
  }

  /// The publication stats
  public var stats: Stat {
    get {
      return Stat(unsafeResultMap: resultMap["stats"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "stats")
    }
  }

  /// The metadata for the post
  public var metadata: Metadatum {
    get {
      return Metadatum(unsafeResultMap: resultMap["metadata"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "metadata")
    }
  }

  /// The date the post was created on
  public var createdAt: String {
    get {
      return resultMap["createdAt"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "createdAt")
    }
  }

  /// The collect module
  public var collectModule: CollectModule {
    get {
      return CollectModule(unsafeResultMap: resultMap["collectModule"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "collectModule")
    }
  }

  /// The reference module
  public var referenceModule: ReferenceModule? {
    get {
      return (resultMap["referenceModule"] as? ResultMap).flatMap { ReferenceModule(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "referenceModule")
    }
  }

  /// ID of the source
  public var appId: String? {
    get {
      return resultMap["appId"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "appId")
    }
  }

  /// If the publication has been hidden if it has then the content and media is not available
  public var hidden: Bool {
    get {
      return resultMap["hidden"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hidden")
    }
  }

  public var reaction: ReactionTypes? {
    get {
      return resultMap["reaction"] as? ReactionTypes
    }
    set {
      resultMap.updateValue(newValue, forKey: "reaction")
    }
  }

  public var mirrors: [String] {
    get {
      return resultMap["mirrors"]! as! [String]
    }
    set {
      resultMap.updateValue(newValue, forKey: "mirrors")
    }
  }

  public var hasCollectedByMe: Bool {
    get {
      return resultMap["hasCollectedByMe"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasCollectedByMe")
    }
  }

  public struct Profile: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Profile"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(ProfileFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var profileFields: ProfileFields {
        get {
          return ProfileFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Stat: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PublicationStats"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(PublicationStatsFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(totalAmountOfMirrors: Int, totalAmountOfCollects: Int, totalAmountOfComments: Int) {
      self.init(unsafeResultMap: ["__typename": "PublicationStats", "totalAmountOfMirrors": totalAmountOfMirrors, "totalAmountOfCollects": totalAmountOfCollects, "totalAmountOfComments": totalAmountOfComments])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var publicationStatsFields: PublicationStatsFields {
        get {
          return PublicationStatsFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct Metadatum: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MetadataOutput"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(MetadataOutputFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var metadataOutputFields: MetadataOutputFields {
        get {
          return MetadataOutputFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct CollectModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FreeCollectModuleSettings", "FeeCollectModuleSettings", "LimitedFeeCollectModuleSettings", "LimitedTimedFeeCollectModuleSettings", "RevertCollectModuleSettings", "TimedFeeCollectModuleSettings", "UnknownCollectModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLFragmentSpread(CollectModuleFields.self),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeFreeCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "FreeCollectModuleSettings", "type": type])
    }

    public static func makeRevertCollectModuleSettings(type: CollectModules) -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "RevertCollectModuleSettings", "type": type])
    }

    public static func makeUnknownCollectModuleSettings() -> CollectModule {
      return CollectModule(unsafeResultMap: ["__typename": "UnknownCollectModuleSettings"])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var collectModuleFields: CollectModuleFields {
        get {
          return CollectModuleFields(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }
    }
  }

  public struct ReferenceModule: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings", "UnknownReferenceModuleSettings"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["FollowOnlyReferenceModuleSettings": AsFollowOnlyReferenceModuleSettings.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeUnknownReferenceModuleSettings() -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "UnknownReferenceModuleSettings"])
    }

    public static func makeFollowOnlyReferenceModuleSettings(type: ReferenceModules) -> ReferenceModule {
      return ReferenceModule(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asFollowOnlyReferenceModuleSettings: AsFollowOnlyReferenceModuleSettings? {
      get {
        if !AsFollowOnlyReferenceModuleSettings.possibleTypes.contains(__typename) { return nil }
        return AsFollowOnlyReferenceModuleSettings(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsFollowOnlyReferenceModuleSettings: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["FollowOnlyReferenceModuleSettings"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(ReferenceModules.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(type: ReferenceModules) {
        self.init(unsafeResultMap: ["__typename": "FollowOnlyReferenceModuleSettings", "type": type])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The reference modules enum
      public var type: ReferenceModules {
        get {
          return resultMap["type"]! as! ReferenceModules
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }
    }
  }
}

public struct CommentFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CommentFields on Comment {
      __typename
      ...CommentBaseFields
      mainPost {
        __typename
        ... on Post {
          __typename
          ...PostFields
        }
        ... on Mirror {
          __typename
          ...MirrorBaseFields
          mirrorOf {
            __typename
            ... on Post {
              __typename
              ...PostFields
            }
            ... on Comment {
              __typename
              ...CommentMirrorOfFields
            }
          }
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Comment"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(CommentBaseFields.self),
      GraphQLField("mainPost", type: .nonNull(.object(MainPost.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The top level post/mirror this comment lives on
  public var mainPost: MainPost {
    get {
      return MainPost(unsafeResultMap: resultMap["mainPost"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "mainPost")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var commentBaseFields: CommentBaseFields {
      get {
        return CommentBaseFields(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public struct MainPost: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Post", "Mirror"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["Post": AsPost.selections, "Mirror": AsMirror.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asPost: AsPost? {
      get {
        if !AsPost.possibleTypes.contains(__typename) { return nil }
        return AsPost(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsPost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Post"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(PostFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var postFields: PostFields {
          get {
            return PostFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMirror: AsMirror? {
      get {
        if !AsMirror.possibleTypes.contains(__typename) { return nil }
        return AsMirror(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMirror: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mirror"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MirrorBaseFields.self),
          GraphQLField("mirrorOf", type: .nonNull(.object(MirrorOf.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The mirror publication
      public var mirrorOf: MirrorOf {
        get {
          return MirrorOf(unsafeResultMap: resultMap["mirrorOf"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "mirrorOf")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var mirrorBaseFields: MirrorBaseFields {
          get {
            return MirrorBaseFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct MirrorOf: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Post", "Comment"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["Post": AsPost.selections, "Comment": AsComment.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              ]
            )
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var asPost: AsPost? {
          get {
            if !AsPost.possibleTypes.contains(__typename) { return nil }
            return AsPost(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsPost: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Post"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(PostFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var postFields: PostFields {
              get {
                return PostFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asComment: AsComment? {
          get {
            if !AsComment.possibleTypes.contains(__typename) { return nil }
            return AsComment(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsComment: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Comment"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLFragmentSpread(CommentMirrorOfFields.self),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var fragments: Fragments {
            get {
              return Fragments(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }

          public struct Fragments {
            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public var commentMirrorOfFields: CommentMirrorOfFields {
              get {
                return CommentMirrorOfFields(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }
    }
  }
}

public struct CommentMirrorOfFields: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment CommentMirrorOfFields on Comment {
      __typename
      ...CommentBaseFields
      mainPost {
        __typename
        ... on Post {
          __typename
          ...PostFields
        }
        ... on Mirror {
          __typename
          ...MirrorBaseFields
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Comment"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLFragmentSpread(CommentBaseFields.self),
      GraphQLField("mainPost", type: .nonNull(.object(MainPost.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The top level post/mirror this comment lives on
  public var mainPost: MainPost {
    get {
      return MainPost(unsafeResultMap: resultMap["mainPost"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "mainPost")
    }
  }

  public var fragments: Fragments {
    get {
      return Fragments(unsafeResultMap: resultMap)
    }
    set {
      resultMap += newValue.resultMap
    }
  }

  public struct Fragments {
    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var commentBaseFields: CommentBaseFields {
      get {
        return CommentBaseFields(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }
  }

  public struct MainPost: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Post", "Mirror"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["Post": AsPost.selections, "Mirror": AsMirror.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var asPost: AsPost? {
      get {
        if !AsPost.possibleTypes.contains(__typename) { return nil }
        return AsPost(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsPost: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Post"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(PostFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var postFields: PostFields {
          get {
            return PostFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMirror: AsMirror? {
      get {
        if !AsMirror.possibleTypes.contains(__typename) { return nil }
        return AsMirror(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMirror: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Mirror"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLFragmentSpread(MirrorBaseFields.self),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var mirrorBaseFields: MirrorBaseFields {
          get {
            return MirrorBaseFields(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}
