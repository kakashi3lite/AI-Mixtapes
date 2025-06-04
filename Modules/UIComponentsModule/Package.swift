// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "UIComponentsModule",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "UIComponentsModule", targets: ["UIComponentsModule"])
    ],
    targets: [
        .target(name: "UIComponentsModule"),
        .testTarget(name: "UIComponentsModuleTests", dependencies: ["UIComponentsModule"])
    ]
)
