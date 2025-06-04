import Foundation

public struct Video: Codable, Sendable, Hashable {
  public var title: String
  public var description: String?
  public var duration: Double?
  public var advertiser: String?
  public var impressions: [URL]
  public var trackings: [Tracking]
  public var medias: [Media]

  enum CodingKeys: CodingKey {
    case title
    case description
    case duration
    case advertiser
    case impressions
    case trackings
    case medias
  }
}

public struct Tracking: Codable, Sendable, Hashable {
  public var event: String
  public var url: URL

  enum CodingKeys: CodingKey {
    case event
    case url
  }
}

public struct Media: Codable, Sendable, Hashable {
  public var url: URL
  public var delivery: String
  public var type: String
  public var bitrate: Int
  public var width: Int
  public var height: Int
  public var scalable: Bool?
  public var maintainAspectRatio: Bool?

  enum CodingKeys: CodingKey {
    case url
    case delivery
    case type
    case bitrate
    case width
    case height
    case scalable
    case maintainAspectRatio
  }
}
