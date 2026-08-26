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
            name: "Finite Primitive",
            targets: ["Finite Primitive"]
        ),

        .library(
            name: "Finite Capacity",
            targets: ["Finite Capacity"]
        ),
        .library(
            name: "Finite Enumerable",
            targets: ["Finite Enumerable"]
        ),
        .library(
            name: "Finite Bounded",
            targets: ["Finite Bounded"]
        ),

        .library(
            name: "Finite",
            targets: ["Finite"]
        ),

        .library(
            name: "Finite Test Support",
            targets: ["Finite Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Finite Primitive",
            dependencies: []
        ),

        .target(
            name: "Finite Capacity",
            dependencies: [
                "Finite Primitive",
                .product(name: "Cardinal", package: "swift-cardinal"),
            ]
        ),
        .target(
            name: "Finite Enumerable",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity",
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Iterator Primitive", package: "swift-iterator"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
            ]
        ),
        .target(
            name: "Finite Bounded",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity",
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Index", package: "swift-index"),
            ]
        ),

        .target(
            name: "Finite",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity",
                "Finite Enumerable",
                "Finite Bounded",
            ]
        ),

        .target(
            name: "Finite Test Support",
            dependencies: [
                "Finite",
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Finite Tests",
            dependencies: [
                "Finite",
                "Finite Test Support",
            ]
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
