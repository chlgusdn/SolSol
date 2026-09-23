import ProjectDescription

/// 모듈 간 의존성. 의존성 방향 규칙은 AGENTS.md 참고.
public enum ModuleDependency: Sendable {
    case core
    case domain
    case clients
    case data
    case designSystem
    case feature(String)
    case external(External)

    public enum External: String, Sendable {
        case composableArchitecture = "ComposableArchitecture"
        case dependencies = "Dependencies"
        case dependenciesMacros = "DependenciesMacros"
        case sqliteData = "SQLiteData"
        case grdb = "GRDB"
        case kronos = "Kronos"
    }

    var targetDependency: TargetDependency {
        switch self {
        case .core:
            .project(target: "Core", path: .relativeToRoot("Projects/Core"))
        case .domain:
            .project(target: "Domain", path: .relativeToRoot("Projects/Domain"))
        case .clients:
            .project(target: "Clients", path: .relativeToRoot("Projects/Clients"))
        case .data:
            .project(target: "Data", path: .relativeToRoot("Projects/Data"))
        case .designSystem:
            .project(target: "DesignSystem", path: .relativeToRoot("Projects/DesignSystem"))
        case let .feature(name):
            .project(target: "\(name)Feature", path: .relativeToRoot("Projects/Features/\(name)"))
        case let .external(external):
            .external(name: external.rawValue)
        }
    }
}
