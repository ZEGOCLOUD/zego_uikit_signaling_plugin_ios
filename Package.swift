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
        .package(url: "https://github.com/ZEGOCLOUD/zego_plugin_adapter_ios.git", from: "2.0.0"),
        .package(url: "https://github.com/zegolibrary/zpns-ios.git", exact: "2.1.0"),
        .package(url: "https://github.com/zegolibrary/zim-ios.git", exact: "2.7.1"),
    ],
    
    targets: [
        .target(name: "ZegoUIKitSignalingPlugin", dependencies: [.product(name: "ZPNs", package: "zpns-ios"), .product(name: "ZegoPluginAdapter", package: "zego_plugin_adapter_ios"), .product(name: "ZIM", package: "zim-ios")], path: "ZegoUIKitSignalingPlugin"),
    ]
)
