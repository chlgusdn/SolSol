import OSLog

extension Logger {
    private static let subsystem = "team.nunu.myApp.solsol"

    public static let app = Logger(subsystem: subsystem, category: "App")
    public static let database = Logger(subsystem: subsystem, category: "Database")
    public static let time = Logger(subsystem: subsystem, category: "Time")
}
