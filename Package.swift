// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "googleads-swift",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "GoogleAds",
      targets: ["GoogleAds"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types.git", from: "1.3.1"),
    .package(url: "https://github.com/zunda-pixel/http-client.git", from: "0.3.0"),
    .package(url: "https://github.com/kewlbear/XMLDocument.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "GoogleAds",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "HTTPClient", package: "http-client"),
        .product(name: "XMLDocument", package: "XMLDocument"),
      ]
    ),
    .testTarget(
      name: "GoogleAdsTests",
      dependencies: ["GoogleAds"]
    ),
  ]
)
