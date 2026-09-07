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
        .library(name: "Finite", targets: ["Finite"]),
        .library(name: "Finite Standard Library Integration", targets: ["Finite Standard Library Integration"]),
        .library(name: "Finite Foundation Library Integration", targets: ["Finite Foundation Library Integration"]),
        .library(name: "Finite Test Support", targets: ["Finite Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-ordinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-atoms/swift-iterator.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Finite",
            dependencies: [
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Iterator", package: "swift-iterator"),
            ],
            path: "Sources/Finite"
        ),
        .target(
            name: "Finite Standard Library Integration",
            dependencies: [
                .target(name: "Finite"),
            ],
            path: "Sources/Finite Standard Library Integration"
        ),
        .target(
            name: "Finite Foundation Library Integration",
            dependencies: [
                .target(name: "Finite"),
                .target(name: "Finite Standard Library Integration"),
            ],
            path: "Sources/Finite Foundation Library Integration"
        ),
        .target(
            name: "Finite Test Support",
            dependencies: [
                .target(name: "Finite"),
                .product(name: "Index Test Support", package: "swift-index"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Finite Tests",
            dependencies: [
                .target(name: "Finite"),
                .target(name: "Finite Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Cardinal Standard Library Integration", package: "swift-cardinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Ordinal Standard Library Integration", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Tagged Standard Library Integration", package: "swift-tagged"),
                .target(name: "Finite Standard Library Integration"),
                .target(name: "Finite Foundation Library Integration"),
            ],
            path: "Tests/Finite Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
