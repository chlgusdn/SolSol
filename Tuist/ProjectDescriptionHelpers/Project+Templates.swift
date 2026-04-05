import ProjectDescription

public enum AppProject {
    public static func make(
        name: String,
        bundleId: String,
        infoPlist: String,
        sources: SourceFilesList,
        resources: ResourceFileElements,
        dependencies: [ModuleDependency]
    ) -> Project {
        let appTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: Module.deploymentTarget,
            infoPlist: .file(path: .relativeToManifest(infoPlist)),
            sources: sources,
            resources: resources,
            dependencies: dependencies.map(\.targetDependency)
        )

        return Project(
            name: name,
            organizationName: Module.organizationName,
            packages: ExternalPackages.all,
            targets: [appTarget]
        )
    }
}
