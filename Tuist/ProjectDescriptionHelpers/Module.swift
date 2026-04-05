import ProjectDescription

public enum Module {
    public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
    public static let organizationName = "SolSol"

    public static func layerProject(
        name: String,
        bundleId: String,
        dependencies: [ModuleDependency] = [],
        hasResources: Bool = false
    ) -> Project {
        let target = Target.target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: bundleId,
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: hasResources ? ["Resources/**"] : nil,
            dependencies: dependencies.map(\.targetDependency)
        )

        let tests = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: name)
            ]
        )

        return Project(
            name: name,
            organizationName: organizationName,
            packages: ExternalPackages.all,
            targets: [
                target,
                tests
            ]
        )
    }

    public static func featureProject(
        name: String,
        bundleId: String,
        dependencies: [ModuleDependency]
    ) -> Project {
        let target = Target.target(
            name: name,
            destinations: .iOS,
            product: .staticFramework,
            bundleId: bundleId,
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: dependencies.map(\.targetDependency)
        )

        let tests = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: name)
            ]
        )

        return Project(
            name: name,
            organizationName: organizationName,
            packages: ExternalPackages.all,
            targets: [
                target,
                tests
            ]
        )
    }
}
