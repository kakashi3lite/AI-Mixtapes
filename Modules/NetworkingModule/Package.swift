// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "NetworkingModule",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "NetworkingModule", targets: ["NetworkingModule"])
    ],
    targets: [
        .target(name: "NetworkingModule"),
        .testTarget(name: "NetworkingModuleTests", dependencies: ["NetworkingModule"])
    ]
)
