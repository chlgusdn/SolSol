import ProjectDescriptionHelpers

let project = Module.layerProject(
    name: "Data",
    bundleId: "com.nunu.SolSol.Data",
    dependencies: [
        .core,
        .domain,
        .grdb
    ]
)
