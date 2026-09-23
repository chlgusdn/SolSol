import ProjectDescription

public enum AppProject {
    public static func make(
        name: String,
        dependencies: [ModuleDependency]
    ) -> Project {
        let infoPlist: [String: Plist.Value] = [
            "CFBundleDisplayName": "솔솔",
            "CFBundleShortVersionString": "1.0.0",
            "CFBundleVersion": "1",
            "UILaunchScreen": [:],
            "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
            "ITSAppUsesNonExemptEncryption": false
        ]

        let app = Target.target(
            name: name,
            destinations: [.iPhone],
            product: .app,
            bundleId: Module.bundleIdPrefix,
            deploymentTargets: Module.deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: dependencies.map(\.targetDependency),
            settings: .settings(base: Module.baseSettings.merging([
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor"
            ]))
        )

        let tests = Target.target(
            name: "\(name)Tests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(Module.bundleIdPrefix).tests",
            deploymentTargets: Module.deploymentTargets,
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: name)],
            settings: .settings(base: Module.baseSettings)
        )

        return Project(
            name: name,
            organizationName: Module.organizationName,
            targets: [app, tests]
        )
    }
}
