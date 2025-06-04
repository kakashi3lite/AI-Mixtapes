// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SiriKitModule",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "SiriKitModule", targets: ["SiriKitModule"])
    ],
    targets: [
        .target(name: "SiriKitModule"),
        .testTarget(name: "SiriKitModuleTests", dependencies: ["SiriKitModule"])
    ]
)
