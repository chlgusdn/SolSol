import ProjectDescription

public enum Module {
    public static let organizationName = "SolSol"
    public static let bundleIdPrefix = "team.nunu.myApp.solsol"
    public static let deploymentTargets: DeploymentTargets = .iOS("18.0")

    /// Swift 6 language mode + Strict Concurrency complete
    public static let baseSettings: SettingsDictionary = [
        "SWIFT_VERSION": "6.0",
        "SWIFT_STRICT_CONCURRENCY": "complete",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES"
    ]

    /// 레이어/기능 모듈 프로젝트 (staticFramework + Swift Testing 테스트 타깃)
    public static func project(
        name: String,
        targetName: String? = nil,
        dependencies: [ModuleDependency] = [],
        testDependencies: [ModuleDependency] = [],
        hasResources: Bool = false
    ) -> Project {
        let targetName = targetName ?? name
        let bundleId = "\(bundleIdPrefix).\(targetName.lowercased())"

        let target = Target.target(
            name: targetName,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: hasResources ? ["Resources/**"] : nil,
            dependencies: dependencies.map(\.targetDependency),
            settings: .settings(base: baseSettings)
        )

        let tests = Target.target(
            name: "\(targetName)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId).tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: targetName)] + testDependencies.map(\.targetDependency),
            settings: .settings(base: baseSettings)
        )

        return Project(
            name: name,
            organizationName: organizationName,
            targets: [target, tests]
        )
    }

    /// Features/Xxx 모듈 — 타깃 이름은 `XxxFeature`
    public static func feature(
        name: String,
        dependencies: [ModuleDependency] = []
    ) -> Project {
        project(
            name: "\(name)Feature",
            targetName: "\(name)Feature",
            dependencies: [
                .clients,
                .domain,
                .designSystem,
                .core,
                .external(.composableArchitecture)
            ] + dependencies
        )
    }
}
