// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Steam",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
        .library(
            name: "Steam",
            targets: ["Steam"]),
    ],
    dependencies: [
        .package(
            name: "CryptoSwift",
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMinor(from: "1.4.2")),
        .package(
            name: "Gzip",
            url: "https://github.com/1024jp/GzipSwift.git",
            .upToNextMinor(from: "5.1.1")),
        .package(
            name: "SwCrypt",
            url: "https://github.com/soyersoyer/SwCrypt.git",
            .upToNextMinor(from: "5.1.4")),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            .upToNextMinor(from: "1.19.0")),
    ],
    targets: [
        .target(
            name: "Steam",
            dependencies: ["CryptoSwift", "Gzip", "SwCrypt", "SwiftProtobuf"],
            exclude: ["Protobuf"]),
        .testTarget(
            name: "SteamTests",
            dependencies: ["Steam"]),
    ]
)
