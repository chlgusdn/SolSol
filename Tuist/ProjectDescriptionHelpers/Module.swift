import ProjectDescription

public enum Module {
    public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
    public static let organizationName = "SolSol"
    public static let swiftLintScript: TargetScript = .pre(
        script: """
        if command -v swiftlint >/dev/null 2>&1; then
          SEARCH_DIR="${SRCROOT}"
          SWIFTLINT_CONFIG=""

          while [ "$SEARCH_DIR" != "/" ]; do
            if [ -f "$SEARCH_DIR/.swiftlint.yml" ]; then
              SWIFTLINT_CONFIG="$SEARCH_DIR/.swiftlint.yml"
              break
            fi
            SEARCH_DIR="$(dirname "$SEARCH_DIR")"
          done

          if [ -z "$SWIFTLINT_CONFIG" ]; then
            echo "warning: SwiftLint config not found. Expected .swiftlint.yml in the repository root."
            exit 0
          fi

          if [ -n "${TARGET_NAME:-}" ] && [ "${TARGET_NAME%Tests}" != "${TARGET_NAME}" ] && [ -d "${SRCROOT}/Tests" ]; then
            LINT_PATH="${SRCROOT}/Tests"
          elif [ -d "${SRCROOT}/Sources" ]; then
            LINT_PATH="${SRCROOT}/Sources"
          else
            LINT_PATH="${SRCROOT}"
          fi

          swiftlint lint --config "$SWIFTLINT_CONFIG" --path "$LINT_PATH" --quiet
        else
          echo "warning: SwiftLint is not installed. Install it to enable local linting."
        fi
        """,
        name: "SwiftLint",
        basedOnDependencyAnalysis: false
    )

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
            scripts: [swiftLintScript],
            dependencies: dependencies.map(\.targetDependency),
            settings: .settings(configurations: [
                .debug(name: "Debug", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "OTHER_MACRO=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1",
                    ],
                ]),
                .release(name: "Release", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "RELEASE=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1",
                    ],
                ]),
            ])
        )

        let tests = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            scripts: [swiftLintScript],
            dependencies: [
                .target(name: name),
            ]
        )

        return Project(
            name: name,
            organizationName: organizationName,
            packages: ExternalPackages.all,
            targets: [
                target,
                tests,
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
            scripts: [swiftLintScript],
            dependencies: dependencies.map(\.targetDependency),
            settings: .settings(configurations: [
                .debug(name: "Debug", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "DEBUG=1",
                        "OTHER_MACRO=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1",
                    ],
                ]),
                .release(name: "Release", settings: [
                    "GCC_PREPROCESSOR_DEFINITIONS": [
                        "RELEASE=1",
                        "FLEXLAYOUT_SWIFT_PACKAGE=1",
                    ],
                ]),
            ])
        )

        let tests = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["Tests/**"],
            scripts: [swiftLintScript],
            dependencies: [
                .target(name: name),
            ]
        )

        return Project(
            name: name,
            organizationName: organizationName,
            packages: ExternalPackages.all,
            targets: [
                target,
                tests,
            ]
        )
    }
}
