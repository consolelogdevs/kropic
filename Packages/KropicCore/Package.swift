// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KropicCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(name: "KropicCore", targets: ["KropicCore"]),
    ],
    targets: [
        .target(name: "KropicCore"),
        .testTarget(name: "KropicCoreTests", dependencies: ["KropicCore"]),
    ]
)
