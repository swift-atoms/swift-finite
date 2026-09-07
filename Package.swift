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

        .library(name: "Finite Foundation Integration", targets: ["Finite Foundation Integration"]),
        .library(name: "Finite Test Support", targets: ["Finite Test Support"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-atoms/swift-difference.git",
            branch: "main"
        ),
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
                .product(name: "Difference", package: "swift-difference"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Iterator", package: "swift-iterator"),
            ],
            path: "Sources/Finite"
        ),
        
        .target(
            name: "Finite Foundation Integration",
            dependencies: [
                .target(name: "Finite"),
            ],
            path: "Sources/Finite Foundation Integration"
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
                .product(name: "Index", package: "swift-index"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .target(name: "Finite Foundation Integration"),
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
