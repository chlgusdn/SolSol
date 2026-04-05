import ProjectDescriptionHelpers

let project = Module.featureProject(
    name: "HomePresentation",
    bundleId: "com.nunu.SolSol.Presentation.Home",
    dependencies: [
        .core,
        .designSystem,
        .domain,
        .factory,
        .flexLayout,
        .pinLayout,
        .fsCalendar
    ]
)
