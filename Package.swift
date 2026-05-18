// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-wd-tagger",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-wd-tagger",
            targets: ["WaifuDiffusionTagger"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WaifuDiffusionTagger",
            resources: [.copy("Resources/selected_tags.csv")]
        ),
        .testTarget(
            name: "swift-wd-taggerTests",
            dependencies: ["WaifuDiffusionTagger"],
            resources: [.copy("Resources")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
