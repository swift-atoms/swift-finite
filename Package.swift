// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-finite",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Finite",
            targets: ["Finite"]
        ),
        .library(
            name: "Finite Standard Library Integration",
            targets: ["Finite Standard Library Integration"]
        ),
        .library(
            name: "Finite Apple Foundation Integration",
            targets: ["Finite Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Finite",
            dependencies: []
        ),
        .target(
            name: "Finite Standard Library Integration",
            dependencies: ["Finite"]
        ),
        .target(
            name: "Finite Apple Foundation Integration",
            dependencies: [
                "Finite",
                "Finite Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Finite Tests",
            dependencies: ["Finite"],
            path: "Tests/Finite Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
