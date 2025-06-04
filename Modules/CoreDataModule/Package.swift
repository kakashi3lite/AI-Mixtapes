// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "CoreDataModule",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "CoreDataModule", targets: ["CoreDataModule"])
    ],
    targets: [
        .target(name: "CoreDataModule"),
        .testTarget(name: "CoreDataModuleTests", dependencies: ["CoreDataModule"])
    ]
)
