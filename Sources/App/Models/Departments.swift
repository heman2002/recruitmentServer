import Vapor
import Fluent
import FluentProvider
import PostgreSQLProvider
final class Department: Model {
  static var entity = "departments"
  var department : String
  static let foreignIdKey = "department"
  var degree : Identifier?
  let storage = Storage()
  init(degree: Degree, department: String) {
        self.degree = degree.id
        self.department = department
  }
  init(row: Row) throws {
        degree = try row.get(Degree.foreignIdKey)
        department = try row.get("department")
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("department", department)
        try row.set(Degree.foreignIdKey, degree)
        return row
  }
}
extension Department: Preparation {
  static func prepare(_ database: Database) throws {
        try database.create(self) { data in
            data.id()
            data.foreignId(for: Degree.self)
            data.string("department")
      }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension Department: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("department", department)
        try node.set(Degree.foreignIdKey, degree)
        return node
    }
}
extension Department: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("degree", Degree.makeQuery().filter("id",degree).first())
        try json.set("department", department)
        return json
    }
}
