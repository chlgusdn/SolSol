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
            scripts: [Module.swiftLintScript],
            dependencies: dependencies.map(\.targetDependency),
            settings: .settings(configurations: [
                .debug(name: "Debug", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "OTHER_MACRO=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1"
                    ],
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ]),
                .release(name: "Release", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "RELEASE=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1"
                    ],
                    "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]
                ])
            ])
        )

        return Project(
            name: name,
            organizationName: Module.organizationName,
            packages: ExternalPackages.all,
            targets: [appTarget]
        )
    }
}
