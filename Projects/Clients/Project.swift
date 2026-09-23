import ProjectDescription
import ProjectDescriptionHelpers

let project = Module.project(
    name: "Clients",
    dependencies: [
        .domain,
        .external(.dependencies),
        .external(.dependenciesMacros)
    ]
)
