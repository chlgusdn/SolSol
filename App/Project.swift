import ProjectDescription
import ProjectDescriptionHelpers

let project = AppProject.make(
    name: "SolSol",
    dependencies: [
        .feature("Onboarding"),
        .feature("Home"),
        .feature("TransactionList"),
        .feature("Statistics"),
        .feature("Budget"),
        .feature("TransactionEditor"),
        .data,
        .clients,
        .domain,
        .designSystem,
        .core,
        .external(.composableArchitecture)
    ]
)
