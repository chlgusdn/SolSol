import ProjectDescription

public enum ModuleDependency {
    case core
    case designSystem
    case domain
    case data
    case homePresentation
    case transactionPresentation
    case factory
    case grdb
    case flexLayout
    case pinLayout
    case fsCalendar

    var targetDependency: TargetDependency {
        switch self {
        case .core:
            return .project(
                target: "SolSolCore",
                path: .relativeToRoot("Projects/Core")
            )

        case .designSystem:
            return .project(
                target: "DesignSystem",
                path: .relativeToRoot("Projects/DesignSystem")
            )

        case .domain:
            return .project(
                target: "Domain",
                path: .relativeToRoot("Projects/Domain")
            )

        case .data:
            return .project(
                target: "Data",
                path: .relativeToRoot("Projects/Data")
            )

        case .homePresentation:
            return .project(
                target: "HomePresentation",
                path: .relativeToRoot("Projects/Presentation/Home")
            )

        case .transactionPresentation:
            return .project(
                target: "TransactionPresentation",
                path: .relativeToRoot("Projects/Presentation/Transaction")
            )

        case .factory:
            return .external(name: "Factory")

        case .grdb:
            return .external(name: "GRDB")

        case .flexLayout:
            return .external(name: "FlexLayout")

        case .pinLayout:
            return .external(name: "PinLayout")

        case .fsCalendar:
            return .external(name: "FSCalendar")
        }
    }
}

public enum ExternalPackages {

    public static let all: [Package] = [
        .remote(
            url: "https://github.com/hmlongco/Factory.git",
            requirement: .upToNextMajor(from: "2.5.3")
        ),
        .remote(
            url: "https://github.com/groue/GRDB.swift.git",
            requirement: .upToNextMajor(from: "7.6.1")
        ),
        .remote(
            url: "https://github.com/layoutBox/FlexLayout.git",
            requirement: .upToNextMajor(from: "2.1.0")
        ),
        .remote(
            url: "https://github.com/layoutBox/PinLayout.git",
            requirement: .upToNextMajor(from: "1.10.5")
        ),
        .remote(
            url: "https://github.com/WenchaoD/FSCalendar.git",
            requirement: .upToNextMajor(from: "2.8.4")
        )
    ]
}
