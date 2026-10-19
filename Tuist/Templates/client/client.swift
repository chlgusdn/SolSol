import ProjectDescription

/// 새 Client 생성: `tuist scaffold client --name Budget`
/// Clients에 인터페이스, Data에 DAO·liveValue·DAO 테스트를 만든다. `bootstrapLive` 등록은 직접 한다.
private let name: Template.Attribute = .required("name")

let template = Template(
    description: "@DependencyClient 인터페이스 + DAO + liveValue + DAO 테스트",
    attributes: [name],
    items: [
        .file(path: "Projects/Clients/Sources/{{ name }}Client.swift", templatePath: "Client.stencil"),
        .file(path: "Projects/Data/Sources/DAO/{{ name }}DAO.swift", templatePath: "DAO.stencil"),
        .file(path: "Projects/Data/Sources/Live/{{ name }}Client+Live.swift", templatePath: "Live.stencil"),
        .file(path: "Projects/Data/Tests/{{ name }}DAOTests.swift", templatePath: "DAOTests.stencil")
    ]
)
