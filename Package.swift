// swift-tools-version: 6.4

import CompilerPluginSupport
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
        .library(name: "Finite Macro Core", targets: ["Finite Macro Core"]),
        .library(name: "Finite Macro", targets: ["Finite Macro"]),
        .library(name: "Finite", targets: ["Finite"]),

        .library(name: "Finite Foundation Integration", targets: ["Finite Foundation Integration"]),
        .library(name: "Finite Test Support", targets: ["Finite Test Support"]),
    ],
    traits: [
        .trait(name: "Polarity", description: "Polarity integration"),
        .trait(name: "Algebra", description: "Algebra integration"),
        .trait(name: "Comparison", description: "Comparison integration"),
        .default(enabledTraits: ["Comparison", "Algebra", "Polarity"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.2"..<"604.0.0"),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-comparison.git", branch: "main"),
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
        .package(url: "https://github.com/swift-atoms/swift-algebra.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-polarity.git", branch: "main"),
    ],
    targets: [
        .testTarget(name: "Finite Macro Tests", dependencies: [
            "Finite Macro",
            "Finite Macro Core",
            .product(name: "SwiftParser", package: "swift-syntax"),
        ]),
        .target(name: "Finite Macro", dependencies: [
            "Finite Macro Plugin",
            "Finite",
            .product(name: "Cardinal", package: "swift-cardinal"),
            .product(name: "Ordinal", package: "swift-ordinal"),
        ]),
        .macro(name: "Finite Macro Plugin", dependencies: [
            "Finite Macro Core",
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .target(name: "Finite Macro Core", dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            .product(name: "Type Algebra Syntax", package: "swift-algebra"),
        ]),
        .target(
            name: "Finite",
            dependencies: [
                .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Comparison"])),
                .product(name: "Comparison", package: "swift-comparison", condition: .when(traits: ["Comparison"])),
                .product(name: "Difference", package: "swift-difference"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Iterator", package: "swift-iterator"),
                .product(name: "Algebra", package: "swift-algebra", condition: .when(traits: ["Algebra"])),
                .product(name: "Polarity", package: "swift-polarity", condition: .when(traits: ["Polarity"])),
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
            path: "Tests/Finite Tests",
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "Finite Comparison Tests",
            dependencies: [
                .target(name: "Finite"),
                .target(name: "Finite Test Support"),
                .product(name: "Cardinal", package: "swift-cardinal", condition: .when(traits: ["Comparison"])),
                .product(name: "Comparison", package: "swift-comparison", condition: .when(traits: ["Comparison"])),
                .product(name: "Index", package: "swift-index", condition: .when(traits: ["Comparison"])),
                .product(name: "Ordinal", package: "swift-ordinal", condition: .when(traits: ["Comparison"])),
                .product(name: "Pair", package: "swift-pair", condition: .when(traits: ["Comparison"])),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Comparison"])),
            ],
            path: "Tests/Finite Comparison Tests"
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

// Generated API consumers must treat visibility diagnostics as hard errors.
for target in package.targets where target.type == .test || target.name.hasSuffix("Consumer Fixtures") {
    target.swiftSettings = (target.swiftSettings ?? []) + [.treatAllWarnings(as: .error)]
}
