import Foundation
import HTTPClient
import HTTPTypes
import HTTPTypesFoundation

public struct GoogleAdsClient<HTTPClient: HTTPClientProtocol & Sendable>: Sendable {
  public var httpClient: HTTPClient
  public var baseUrl = URL(string: "https://googleads.g.doubleclick.net/")!
  public var framework: String = "afma-sdk-i-v11.12.0"
  public var isTest: Bool
  public var clientId: String
  public var area: String
  public var userAgent: String

  /// Initialize GoogleAds
  /// - Parameters:
  ///   - httpClient: HTTPClient
  ///   - isTest: isTest
  ///   - clientId: Google AdMob ID(Example: ca-app-pub-9106234573254233)
  ///   - area: Area(Example: ja)
  ///   - nativeVersion: Native Version(Example: 3)
  ///   - userAgent: UserAgent(Example: Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148)
  public init(
    httpClient: HTTPClient,
    isTest: Bool,
    clientId: String,
    area: String,
    userAgent: String
  ) {
    self.httpClient = httpClient
    self.isTest = true
    self.clientId = clientId
    self.area = area
    self.userAgent = userAgent
  }

  /// Fetch Native Ads from Google Ads
  /// - Parameters:
  ///   - slotName: Ad unit ID(Ex: 9934595423)
  ///   - nativeVersion: Native Version(Ex: 3)
  ///   - templateNumbers: 1, 2, 3, 4, 5
  /// - Returns: [Ad]
  public func fetchNativeAds(
    slotName: String,
    maxCount: Int = 1,
    nativeVersion: Int,
    templates: [Ad.Template]
  ) async throws -> [Ad] {
    let queryItems: [URLQueryItem] = [
      .init(name: "adtest", value: self.isTest ? "on" : "off"),
      .init(name: "client", value: self.clientId),
      .init(name: "hl", value: self.area),
      .init(name: "js", value: self.framework),
      .init(
        name: "sra_urls",
        value: (0..<maxCount).map { _ in "slotname=\(slotName)" }.joined(separator: ",")
      ),
      .init(
        name: "native_templates",
        value: templates.map(\.rawValue).map(String.init).joined(separator: ",")
      ),
      .init(name: "native_version", value: String(nativeVersion)),
    ]

    let endpoint =
      baseUrl
      .appending(path: "/mads/gma")
      .appending(queryItems: queryItems)

    let request = HTTPRequest(
      method: .get,
      url: endpoint,
      headerFields: [
        .userAgent: self.userAgent
      ]
    )

    let (data, _) = try await httpClient.execute(for: request, from: nil)

    let response = try JSONDecoder().decode(SlotsResponse.self, from: data)

    return response.slots.flatMap(\.ads)
  }
}
