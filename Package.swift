// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZegoUIKitSignalingPlugin",
    
    platforms: [.iOS(.v12)],
    
    products: [
        .library(name: "ZegoUIKitSignalingPlugin", targets: ["ZegoUIKitSignalingPlugin"])
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/ZEGOCLOUD/zego_plugin_adapter_ios.git", from: "2.0.0")
    ],
    
    targets: [
        .target(name: "ZegoUIKitSignalingPlugin", dependencies: [.product(name: "ZegoPluginAdapter", package: "zego_plugin_adapter_ios")], path: "ZegoUIKitSignalingPlugin"),
    ]
)
