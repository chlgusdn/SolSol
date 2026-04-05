import Foundation

enum DependencyBootstrapper {
    static func bootstrap() async {
        await DataAssembly.initializeSQLAccess()
        DataAssembly.register()
        DomainAssembly.register()
        UsecaseAssembly.register()
        HomeAssembly.register()
        TransactionAssembly.register()
    }
}
