// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIBezierPath-Superpowers",
    platforms: [.iOS(.v12), .macCatalyst(.v13), .visionOS(.v1)],
    products: [
        .library(
            name: "UIBezierPath-Superpowers",
            targets: ["UIBezierPath-Superpowers"]),
    ],
    targets: [
        .target(
            name: "UIBezierPath-Superpowers",
            path: ".",
            sources: ["UIBezierPath+Superpowers.swift"])
    ]
)
