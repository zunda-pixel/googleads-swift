import Foundation

#if !os(macOS) || !os(Linux)
  import JebiXML
#endif

#if canImport(FoundationXML)
  import FoundationXML
#endif

extension Video {
  init(xmlData: Data) throws {
    #if os(macOS)
      let document = try XMLDocument(data: xmlData)
    #else
      let document = try XMLDocument(data: xmlData, options: 0)
    #endif
    guard let title = try document.nodes(forXPath: "//AdTitle").first?.stringValue else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: [Video.CodingKeys.title], debugDescription: "title is missing"))
    }

    let description = try document.nodes(forXPath: "//Description").first?.stringValue

    guard let durationString = try document.nodes(forXPath: "//Duration").first?.stringValue else {
      throw DecodingError.dataCorrupted(
        .init(
          codingPath: [Video.CodingKeys.description], debugDescription: "description is missing"
        )
      )
    }

    let durationComponents = try durationString.split(separator: ":").map {
      if let int = Int($0) {
        return int
      } else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [Video.CodingKeys.duration], debugDescription: "duration is not a number"
          )
        )
      }
    }

    guard durationComponents.count == 3 else {
      throw DecodingError.dataCorrupted(
        .init(codingPath: [Video.CodingKeys.duration], debugDescription: "duration is missing")
      )
    }

    let duration = Double(
      durationComponents[0] * 3600 + durationComponents[1] * 60 + durationComponents[2]
    )

    let advertiser = try document.nodes(forXPath: "//Advertiser").first?.stringValue

    let impressions = try document.nodes(forXPath: "//Impression").map {
      if let url = $0.stringValue.map({ URL(string: $0) }) as? URL {
        return url
      } else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [Video.CodingKeys.impressions], debugDescription: "impressions is missing"
          )
        )
      }
    }
    let trackings = try document.nodes(forXPath: "//Tracking").map {
      guard let element = $0 as? XMLElement else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Tracking.CodingKeys.event], debugDescription: "event is missing")
        )
      }

      guard let event = element.attribute(forName: "event")?.stringValue else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Tracking.CodingKeys.event], debugDescription: "event is missing")
        )
      }

      guard let url = $0.stringValue.map({ URL(string: $0) }) as? URL else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Tracking.CodingKeys.event], debugDescription: "event is missing")
        )
      }

      return Tracking(event: event, url: url)
    }
    let jsonDecoder = JSONDecoder()

    let medias = try document.nodes(forXPath: "//MediaFile").map {
      guard let element = $0 as? XMLElement else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [Media.CodingKeys.delivery], debugDescription: "media is can not be decoded"
          )
        )
      }

      guard let url = $0.stringValue.map({ URL(string: $0) }) as? URL else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.url], debugDescription: "url is missing")
        )
      }

      guard let delivery = element.attribute(forName: "delivery")?.stringValue else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.delivery], debugDescription: "delivery is missing")
        )
      }
      guard let type = element.attribute(forName: "type")?.stringValue else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.type], debugDescription: "type is missing")
        )
      }
      guard let bitrate = element.attribute(forName: "bitrate")?.stringValue.map(Int.init) as? Int
      else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.bitrate], debugDescription: "bitrate is missing")
        )
      }
      guard let width = element.attribute(forName: "width")?.stringValue.map(Int.init) as? Int
      else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.width], debugDescription: "width is missing")
        )
      }
      guard let height = element.attribute(forName: "height")?.stringValue.map(Int.init) as? Int
      else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.height], debugDescription: "height is missing")
        )
      }
      guard let scalable = element.attribute(forName: "scalable")?.stringValue else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.scalable], debugDescription: "scalable is missing")
        )
      }
      guard let maintainAspectRatio = element.attribute(forName: "maintainAspectRatio")?.stringValue
      else {
        throw DecodingError.dataCorrupted(
          .init(
            codingPath: [Media.CodingKeys.maintainAspectRatio],
            debugDescription: "maintainAspectRatio is missing"
          )
        )
      }

      return try Media(
        url: url,
        delivery: delivery,
        type: type,
        bitrate: bitrate,
        width: width,
        height: height,
        scalable: jsonDecoder.decode(Bool.self, from: Data(scalable.utf8)),
        maintainAspectRatio: jsonDecoder.decode(Bool.self, from: Data(maintainAspectRatio.utf8))
      )
    }

    self = Video(
      title: title,
      description: description,
      duration: duration,
      advertiser: advertiser,
      impressions: impressions,
      trackings: trackings,
      medias: medias
    )
  }
}
