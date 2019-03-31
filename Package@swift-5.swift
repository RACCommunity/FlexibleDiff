// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "FlexibleDiff",
    products: [
        .library(name: "FlexibleDiff", targets: ["FlexibleDiff"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "FlexibleDiff", path: "FlexibleDiff"),
        .testTarget(name: "FlexibleDiffTests", dependencies: ["FlexibleDiff", "Quick", "Nimble"], path: "FlexibleDiffTests"),
    ],
    swiftLanguageVersions: [.v5]
)
