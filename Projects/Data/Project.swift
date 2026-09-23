import ProjectDescription
import ProjectDescriptionHelpers

let project = Module.project(
    name: "Data",
    dependencies: [
        .clients,
        .domain,
        .core,
        .external(.dependencies),
        .external(.sqliteData),
        .external(.grdb),
        .external(.kronos)
    ]
)
