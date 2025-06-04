// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AIModule",
    platforms: [
        .iOS(.v15), .macOS(.v12)
    ],
    products: [
        .library(name: "AIModule", targets: ["AIModule"])
    ],
    targets: [
        .target(name: "AIModule"),
        .testTarget(name: "AIModuleTests", dependencies: ["AIModule"])
    ]
)
