// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConfluxSwift",
    platforms: [
        .macOS(.v10_12), .iOS(.v10)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ConfluxSwift",
            targets: ["ConfluxSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(name: "TweetNacl", url: "https://github.com/lishuailibertine/tweetnacl-swiftwrap", from: "1.0.5"),
        .package(name: "Secp256k1Swift", url: "https://github.com/mathwallet/Secp256k1Swift.git", from: "2.0.0"),
        .package(name:"BIP39swift", url: "https://github.com/mathwallet/BIP39swift", from: "1.0.1"),
        .package(name:"Base32Swift", url: "https://github.com/lishuailibertine/Base32Swift", from: "0.0.2"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.4"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ConfluxSwift",
            dependencies: [
                "CryptoSwift",
                .product(name: "BIP32Swift", package: "Secp256k1Swift"),
                "TweetNacl",
                "BIP39swift",
                "Base32Swift",
                "PromiseKit"
            ]
        ),
        .testTarget(
            name: "ConfluxSwiftTests",
            dependencies: ["ConfluxSwift"]),
    ]
)
