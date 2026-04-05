// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SolSolDependencies",
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.6.1"),
        .package(url: "https://github.com/layoutBox/FlexLayout.git", from: "2.1.0"),
        .package(url: "https://github.com/layoutBox/PinLayout.git", from: "1.10.5"),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git", from: "2.8.4"),
        .package(url: "https://github.com/facebook/yoga.git", from: "3.2.1")
    ]
)
