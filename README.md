# googleads-swift

```swift
import Foundation
import GoogleAds

let client = GoogleAdsClient(
  httpClient: .urlSession(.shared),
  isTest: true,
  clientId: "ca-app-pub-3940256099942544",
  area: "ja",
  userAgent:
    "Mozilla/5.0 (iPhone; CPU iPhone OS 18_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
)
let ads = try await client.fetchNativeAds(
  slotName: "3986624511",
  maxCount: 10,
  nativeVersion: 3,
  templates: [.small, .medium, .large, .video]
)
```


```swift
let ads = [
  Ad(
    uuid: EF9886D9-911F-31DE-4992-C018203BBD08,
    type: "native",
    headline: "Flood–It!",
    body: "Flood-it! Install Flood-It App for free! Free Popular Casual Game",
    image: Image(
      url: https://lh3.googleusercontent.com/7pSuz6KU_tyRCYutzMT9fQ6zDwl1Lm4jGMjFpb,
      width: 270,
      height: 480,
      scale: 1,
      isTransparent: false,
      isAnimated: false
    ),
    secondaryImage: nil,
    trackingUrlsAndAction: TrackingUrlsAndAction(
      clickActions: [
        ClickActions(
          type: 1,
          url: https://apps.apple.com/app/id476943146?mt=8,
          u2FinalUrl: https://apps.apple.com/app/id476943146?mt=8
        )
      ],
      impressionTrackingUrls: [
        https://pagead2.googleadservices.com/pagead/adview?ai=CztFupMpBZ4vaDb3ys8IPjrW5sA0A
      ],
      googleClickTrackingUrl: https://googleads.g.doubleclick.net/aclk?sa=L&ai=Ct2ZA&adurl=https://apps.apple.com/app/id476943146%3Fmt%3D8,
      creativeConversionUrlWithoutLabel: https://googleads.g.doubleclick.net/pagead/conversion/?ai=Ct7elpMpBZ4vaDb3ys8,
      useAppStoreOverlay: false
    ),
    template: .small,
    callToCction: "INSTALL",
    attribution: nil,
    images: [
      Image(
        url: https://lh3.googleusercontent.com/7pSuz6KU_tyRCYutzMT9fQ6zDwl1Lm4jGMjFpb8vqMEIUqxRR63SC7x7EJoXv0vBFCNCgF_E=w270-h480-n-e7-l80-rj,
        width: 270,
        height: 480,
        scale: 1,
        isTransparent: false,
        isAnimated: false
      ),
      Image(
        url: https://lh3.googleusercontent.com/z9J99SJgooFyDQi99XX4u4Gwj,
        width: 270,
        height: 480),
        scale: 1),
        isTransparent: false,
        isAnimated: false
      ),
    ],
    video: nil,
    adType: AdType.appStore(
      appIcon: Image(
        url: https://lh3.googleusercontent.com/FmxHh96FckkqyE16a6iMNnotA2vv0Jra5UHQ1EivFVDus-aqa25ksdBBIfs3KlXKfdaOB71Xtw=w128-h128-n-e7,
        width: 128,
        height: 128,
        scale: 1,
        isTransparent: true,
        isAnimated: nil
      ),
      price: "FREE",
      rating: 3.5842702,
      store: "App Store",
      appId: "476943146"
    )
  )
]
```
