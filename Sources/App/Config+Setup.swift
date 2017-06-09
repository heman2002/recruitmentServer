import FluentProvider
import PostgreSQLProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }

    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(PostgreSQLProvider.Provider.self)
    }

    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(District.self)
        preparations.append(College.self)
        preparations.append(Degree.self)
        preparations.append(Department.self)
        preparations.append(Pivot<College, Degree>)
        preparations.append(Recruit.self)
        preparations.append(Admin.self)
    }
}
