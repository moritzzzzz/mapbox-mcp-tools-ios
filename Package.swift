// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MapboxMCPTools",
    platforms: [
        .iOS(.v14)  // Mapbox Maps SDK v11 requires iOS 14+
    ],
    products: [
        .library(
            name: "MapboxMCPTools",
            targets: ["MapboxMCPTools"]
        ),
    ],
    dependencies: [
        // Mapbox Maps SDK v11
        .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "MapboxMCPTools",
            dependencies: [
                .product(name: "MapboxMaps", package: "mapbox-maps-ios")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "MapboxMCPToolsTests",
            dependencies: ["MapboxMCPTools"],
            path: "Tests"
        ),
    ]
)
