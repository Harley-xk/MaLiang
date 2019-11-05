// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MaLiang",
    products: [
        .library(
            name: "MaLiang",
            targets: ["MaLiang"]),
    ],
    targets: [
        .target(
            name: "MaLiang",
            path: "./MaLiang",
            sources: ["Classes"])
    ]
)
