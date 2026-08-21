// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-finite-primitives",
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
            name: "Finite Capacity Primitives",
            targets: ["Finite Capacity Primitives"]
        ),
        .library(
            name: "Finite Enumerable Primitives",
            targets: ["Finite Enumerable Primitives"]
        ),
        .library(
            name: "Finite Bounded Primitives",
            targets: ["Finite Bounded Primitives"]
        ),

        .library(
            name: "Finite Primitives",
            targets: ["Finite Primitives"]
        ),

        .library(
            name: "Finite Primitives Test Support",
            targets: ["Finite Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-cardinal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-ordinal-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-tagged-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-index-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-iterator-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Finite Primitive",
            dependencies: []
        ),

        .target(
            name: "Finite Capacity Primitives",
            dependencies: [
                "Finite Primitive",
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
            ]
        ),
        .target(
            name: "Finite Enumerable Primitives",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity Primitives",
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
            ]
        ),
        .target(
            name: "Finite Bounded Primitives",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity Primitives",
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
            ]
        ),

        .target(
            name: "Finite Primitives",
            dependencies: [
                "Finite Primitive",
                "Finite Capacity Primitives",
                "Finite Enumerable Primitives",
                "Finite Bounded Primitives",
            ]
        ),

        .target(
            name: "Finite Primitives Test Support",
            dependencies: [
                "Finite Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Finite Primitives Tests",
            dependencies: [
                "Finite Primitives",
                "Finite Primitives Test Support",
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
