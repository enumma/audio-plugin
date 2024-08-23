// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EnummaAudioPlugin",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "EnummaAudioPlugin",
            targets: ["AudioPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "AudioPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/AudioPluginPlugin"),
        .testTarget(
            name: "AudioPluginPluginTests",
            dependencies: ["AudioPluginPlugin"],
            path: "ios/Tests/AudioPluginPluginTests")
    ]
)