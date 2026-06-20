import ProjectDescriptionHelpers

let project = Module.featureProject(
    name: "TransactionPresentation",
    bundleId: "com.nunu.SolSol.Presentation.Transaction",
    dependencies: [
        .core,
        .designSystem,
        .domain,
        .flexLayout,
        .pinLayout
    ]
)
