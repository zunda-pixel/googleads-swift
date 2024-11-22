import Foundation

struct SlotsResponse: Decodable {
  var slots: [AdsResponse]
}

struct AdsResponse: Decodable {
  var ads: [Ad]

  private enum CodingKeys: CodingKey {
    case ads
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    // sometimes ads key is missing
    self.ads = try container.decodeIfPresent([Ad].self, forKey: .ads) ?? []
  }
}

public struct Ad: Decodable, Sendable, Hashable {
  public var uuid: UUID
  public var type: String
  public var headline: String
  public var body: String?
  public var image: Image
  public var secondaryImage: Image?
  public var trackingUrlsAndAction: TrackingUrlsAndAction
  public var templateId: Int
  public var callToCction: String
  public var attribution: Attribution?
  public var images: [Image]?
  public var video: VideoContent?
  public var adType: AdType

  public enum AdType: Codable, Sendable, Hashable {
    case normal(advertiser: String)
    case appStore(appIcon: Image, price: String, rating: Double?, store: String?, appId: String?)
  }

  private enum CodingKeys: String, CodingKey {
    case uuid
    case type
    case headline
    case body
    case image
    case secondaryImage = "secondary_image"
    case trackingUrlsAndAction = "tracking_urls_and_actions"
    case templateId = "template_id"
    case callToCction = "call_to_action"
    case advertiser
    case attribution
    case images
    case video
    case appIcon = "app_icon"
    case rating
    case price
    case store
    case appId = "app_id"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.uuid = try container.decode(UUID.self, forKey: .uuid)
    self.type = try container.decode(String.self, forKey: .type)
    self.headline = try container.decode(String.self, forKey: .headline)
    self.body = try container.decodeIfPresent(String.self, forKey: .body)
    self.image = try container.decode(Image.self, forKey: .image)
    self.secondaryImage = try container.decodeIfPresent(Image.self, forKey: .secondaryImage)
    self.trackingUrlsAndAction = try container.decode(
      TrackingUrlsAndAction.self,
      forKey: .trackingUrlsAndAction
    )
    // sometime templateId is String
    self.templateId =
      if let templateId = try? container.decode(Int.self, forKey: .templateId) {
        templateId
      } else if let templateId = Int(try container.decode(String.self, forKey: .templateId)) {
        templateId
      } else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: container.codingPath + [CodingKeys.templateId],
            debugDescription: "template_id is not Number"
          ))
      }
    self.callToCction = try container.decode(String.self, forKey: .callToCction)
    // sometimes attribution is empty object it has no value, Server should return nil.
    self.attribution = try? container.decode(Attribution.self, forKey: .attribution)

    self.images = try container.decodeIfPresent([Image].self, forKey: .images)
    self.video = try container.decodeIfPresent(VideoContent.self, forKey: .video)

    self.adType =
      if let advertiser = try container.decodeIfPresent(String.self, forKey: .advertiser) {
        .normal(advertiser: advertiser)
      } else {
        .appStore(
          appIcon: try container.decode(Image.self, forKey: .appIcon),
          price: try container.decode(String.self, forKey: .price),
          rating: try container.decodeIfPresent(Double.self, forKey: .rating),
          store: try container.decodeIfPresent(String.self, forKey: .store),
          appId: try container.decodeIfPresent(String.self, forKey: .appId)
        )
      }
  }
}

public struct VideoContent: Codable, Sendable, Hashable {
  public var video: Video
  public var thumbnails: [Image]
  public var flags: [KeyValue]
  public var language: String?
  public var width: Int?
  public var height: Int?

  private enum CodingKeys: String, CodingKey {
    case video = "vast_xml"
    case thumbnails
    case flags
    case language
    case width
    case height
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let videoXml = try container.decode(String.self, forKey: .video)
    self.video = try Video(xmlData: Data(videoXml.utf8))
    self.thumbnails = try container.decode([Image].self, forKey: .thumbnails)
    self.flags = try container.decode([KeyValue].self, forKey: .flags)
    self.language = try container.decodeIfPresent(String.self, forKey: .language)
    self.width = try container.decodeIfPresent(Int.self, forKey: .width)
    self.height = try container.decodeIfPresent(Int.self, forKey: .height)
  }
}

public struct KeyValue: Codable, Sendable, Hashable {
  public var key: String
  public var value: String
}

public struct Attribution: Codable, Sendable, Hashable {
  public var text: String
  public var url: URL
  public var image: Image
}

public struct Image: Codable, Sendable, Hashable {
  public var url: URL
  public var width: Int?
  public var height: Int?
  public var scale: Int?
  public var isTransparent: Bool?
  public var isAnimated: Bool?

  private enum CodingKeys: String, CodingKey {
    case url
    case width
    case height
    case scale
    case isTransparent = "is_transparent"
    case isAnimated = "is_animated"
  }
}

public struct TrackingUrlsAndAction: Codable, Sendable, Hashable {
  public var clickActions: [ClickActions]
  public var impressionTrackingUrls: [URL]
  public var googleClickTrackingUrl: URL?
  public var creativeConversionUrlWithoutLabel: URL
  public var useAppStoreOverlay: Bool

  private enum CodingKeys: String, CodingKey {
    case clickActions = "click_actions"
    case impressionTrackingUrls = "impression_tracking_urls"
    case googleClickTrackingUrl = "google_click_tracking_url"
    case creativeConversionUrlWithoutLabel = "creative_conversion_url_without_label"
    case useAppStoreOverlay = "use_app_store_overlay"
  }
}

public struct ClickActions: Codable, Sendable, Hashable {
  public var type: Int
  public var url: URL
  public var u2FinalUrl: URL?

  private enum CodingKeys: String, CodingKey {
    case type
    case url
    case u2FinalUrl = "u2_final_url"
  }
}
