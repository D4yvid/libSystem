// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "System",

    products: [
        .library(name: "System", targets: ["System"]),
        .library(name: "SystemDevices", targets: ["SystemDevices"]),
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
