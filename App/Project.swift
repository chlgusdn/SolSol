import ProjectDescription
import ProjectDescriptionHelpers

let project = AppProject.make(
    name: "SolSol",
    bundleId: "team.nunu.myApp.solsol",
    infoPlist: "Resources/Info.plist",
    sources: ["Sources/**"],
    resources: [
        .glob(
            pattern: "Resources/**",
            excluding: ["Resources/Info.plist"]
        )
    ],
    dependencies: [
        .core,
        .designSystem,
        .domain,
        .data,
        .homePresentation,
        .transactionPresentation,
        .factory
    ]
)
