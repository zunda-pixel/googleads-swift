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
  ],
  targets: [
    .target(
      name: "GoogleAds",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        .product(name: "HTTPClient", package: "http-client"),
      ]
    ),
    .testTarget(
      name: "GoogleAdsTests",
      dependencies: ["GoogleAds"]
    ),
  ]
)

#if !os(macOS) && !os(Linux)
package.dependencies.append(.package(url: "https://github.com/zunda-pixel/XMLDocument.git", branch: "fix-error-linux"))
package.targets[0].dependencies.append(.product(name: "JebiXML", package: "XMLDocument"))
#endif
