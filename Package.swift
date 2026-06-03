// swift-tools-version: 5.9
// SPDX-License-Identifier: MIT
import PackageDescription

let package = Package(
    name: "OneDisplay",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "OneDisplay")
    ]
)
