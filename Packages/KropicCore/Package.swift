// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KropicCore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(name: "KropicCore", targets: ["KropicCore"]),
    ],
    targets: [
        .target(name: "KropicCore", resources: [.process("Resources")]),
        .testTarget(name: "KropicCoreTests", dependencies: ["KropicCore"]),
    ]
)
