// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

let package = Package(
    name: "SolSolDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.26.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.17.1"
        ),
        .package(
            url: "https://github.com/pointfreeco/sqlite-data",
            from: "1.12.0"
        ),
        .package(
            url: "https://github.com/MobileNativeFoundation/Kronos.git",
            from: "4.3.1"
        )
    ]
)
