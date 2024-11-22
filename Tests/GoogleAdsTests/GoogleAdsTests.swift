import Testing

@testable import GoogleAds

let client = GoogleAdsClient(
  httpClient: .urlSession(.shared),
  isTest: true,
  clientId: "ca-app-pub-3940256099942544",
  area: "ja",
  userAgent:
    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
)

@Test
func fetchNativeAds() async throws {
  let ads = try await client.fetchNativeAds(
    slotName: "3986624511",
    maxCount: 5,
    nativeVersion: 3,
    templates: [.video, .large, .medium, .small]
  )

  print(ads.map(\.headline))
}
