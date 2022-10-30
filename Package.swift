// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "swift-steam",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Steam",
            targets: ["Steam"]
        )
    ],
    dependencies: [
        .package(
            name: "CryptoSwift",
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .upToNextMinor(from: "1.6.0")
        ),
        .package(
            name: "Gzip",
            url: "https://github.com/1024jp/GzipSwift.git",
            .upToNextMinor(from: "5.2.0")
        ),
        .package(
            name: "SwCrypt",
            url: "https://github.com/soyersoyer/SwCrypt.git",
            .upToNextMinor(from: "5.1.4")
        ),
        .package(
            name: "SwiftProtobuf",
            url: "https://github.com/apple/swift-protobuf.git",
            .upToNextMinor(from: "1.20.2")
        )
    ],
    targets: [
        .target(
            name: "Steam",
            dependencies: ["CryptoSwift", "Gzip", "SwCrypt", "SwiftProtobuf"],
            exclude: ["Protobuf"]
        ),
        .testTarget(
            name: "SteamTests",
            dependencies: ["Steam"]
        )
    ],
    swiftLanguageVersions: [.v5]
)

#if swift(>=5.6)
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    )
#endif
