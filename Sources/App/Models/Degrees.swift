import Vapor
import Fluent
import FluentProvider
import Node
import JSON
import PostgreSQLProvider
final class Degree: Model {
  static var entity = "degrees"
  static let foreignIdKey = "degree"
  static let idKey = "id"
  var degree : String
  let storage = Storage()
  init(degree: String) {
        self.degree = degree
  }
  init(row: Row) throws {
        degree = try row.get("degree")
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("degree", degree)
        return row
  }
}
extension Degree: Preparation {
  static func prepare(_ database: Database) throws {
      try database.create(self) { data in
          data.id()
          data.string("degree")
    }
  }
  static func revert(_ database: Database) throws {
      try database.delete(self)
  }
}
extension Degree: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("degree", degree)
        return node
    }
}
extension Degree: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("degree", degree)
        return json
    }
}
extension Degree {
    var departments: Children<Degree, Department> {
        return children()
    }
    var colleges: Siblings<Degree, College, Pivot<College, Degree>> {
        return siblings()
    }
}
