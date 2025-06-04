// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "VisualizationModule",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "VisualizationModule", targets: ["VisualizationModule"])
    ],
    targets: [
        .target(name: "VisualizationModule"),
        .testTarget(name: "VisualizationModuleTests", dependencies: ["VisualizationModule"])
    ]
)
