import Foundation
import DOMParser
import XPath
import XMLCore

extension Video {
  init(xmlData: Data) throws {
    let document = try DOMParser.parse(bytes: Array(xmlData).span)
    let title = try document.firstString(forXPath: "//AdTitle")

    let description = try document.firstString(forXPath: "//Description")

    let durationString = try document.firstString(forXPath: "//Duration")

    let durationComponents = try durationString?.split(separator: ":").map {
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

    let duration: Double?

    if let durationComponents {
      guard durationComponents.count == 3 else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Video.CodingKeys.duration], debugDescription: "duration is missing")
        )
      }

      duration = Double(
        durationComponents[0] * 3600 + durationComponents[1] * 60 + durationComponents[2]
      )
    } else {
      duration = nil
    }

    let advertiser = try document.firstString(forXPath: "//Advertiser")

    let impressions = try document.nodes(forXPath: "//Impression").map {
      if let url = URL(string: document.stringValue(of: $0)) {
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
      guard let event = document.attribute(named: "event", of: $0) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Tracking.CodingKeys.event], debugDescription: "event is missing")
        )
      }

      guard let url = URL(string: document.stringValue(of: $0)) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Tracking.CodingKeys.event], debugDescription: "event is missing")
        )
      }

      return Tracking(event: event, url: url)
    }

    let medias = try document.nodes(forXPath: "//MediaFile").map {
      let url = URL(string: document.stringValue(of: $0))

      guard let delivery = document.attribute(named: "delivery", of: $0) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.delivery], debugDescription: "delivery is missing")
        )
      }
      guard let type = document.attribute(named: "type", of: $0) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.type], debugDescription: "type is missing")
        )
      }
      guard let bitrate = document.attribute(named: "bitrate", of: $0).flatMap(Int.init) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.bitrate], debugDescription: "bitrate is missing")
        )
      }
      guard let width = document.attribute(named: "width", of: $0).flatMap(Int.init) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.width], debugDescription: "width is missing")
        )
      }
      guard let height = document.attribute(named: "height", of: $0).flatMap(Int.init) else {
        throw DecodingError.dataCorrupted(
          .init(codingPath: [Media.CodingKeys.height], debugDescription: "height is missing")
        )
      }
      let scalable = document.attribute(named: "scalable", of: $0)
      let maintainAspectRatio = document.attribute(named: "maintainAspectRatio", of: $0)

      let jsonDecoder = JSONDecoder()

      return try Media(
        url: url,
        delivery: delivery,
        type: type,
        bitrate: bitrate,
        width: width,
        height: height,
        scalable: scalable.map { try jsonDecoder.decode(Bool.self, from: Data($0.utf8)) },
        maintainAspectRatio: maintainAspectRatio.map {
          try jsonDecoder.decode(Bool.self, from: Data($0.utf8))
        }
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

private extension Document {
  func nodes(forXPath expression: String) throws -> [Document.Reference] {
    try XPath.Expression.parse(expression)
      .nodes(in: self, with: XPath.Context(node: self.root))
  }

  func firstString(forXPath expression: String) throws -> String? {
    try nodes(forXPath: expression).first.map { stringValue(of: $0) }
  }

  func stringValue(of reference: Document.Reference) -> String {
    let view = self.view(of: reference)
    switch view.kind {
    case .document, .element:
      var string = ""
      var child = self.firstChild(of: reference)
      while let current = child {
        string += stringValue(of: current)
        child = self.nextSibling(of: current)
      }
      return string
    default:
      guard let value = view.value else { return "" }
      return String(decoding: value)
    }
  }

  func attribute(named name: String, of reference: Document.Reference) -> String? {
    var attribute = self.firstAttribute(of: reference)
    while let current = attribute {
      let view = self.view(of: current)
      if let attributeName = view.name,
        String(decoding: attributeName.local) == name,
        let value = view.value
      {
        return String(decoding: value)
      }
      attribute = self.nextAttribute(after: current)
    }
    return nil
  }
}

private extension String {
  init(decoding bytes: borrowing Span<XML.Byte>) {
    self = bytes.withUnsafeBufferPointer { String(decoding: $0, as: UTF8.self) }
  }
}
