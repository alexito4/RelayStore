// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RelayStore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "RelayStore",
            targets: ["RelayStore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.29.0"),
    ],
    targets: [
        .target(
            name: "RelayStore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "RelayStoreTests",
            dependencies: ["RelayStore"]
        ),
    ]
)
