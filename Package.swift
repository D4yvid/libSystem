// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "System",

    products: [
        .library(name: "System", targets: ["System"]),
        .library(name: "SystemDevices", targets: ["SystemDevices"]),
        .executable(name: "diskutil", targets: ["diskutil"]),
    ],

    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],

    targets: [
        .systemLibrary(name: "CUDevices"),

        .target(
            name: "System",

            dependencies: [
                .target(name: "SystemDevices")
            ]
        ),

        .target(
            name: "SystemDevices",

            dependencies: [
                .target(name: "CUDevices")
            ]
        ),

        .executableTarget(
            name: "diskutil",

            dependencies: [
                .target(name: "System"),
                .target(name: "SystemDevices"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),

        .testTarget(
            name: "SystemTests",
            dependencies: [
                .target(name: "System")
            ]
        ),

        .testTarget(
            name: "SystemDevicesTests",
            dependencies: [
                .target(name: "SystemDevices")
            ]
        ),
    ]
)
