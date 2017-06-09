import Vapor
import Fluent
import FluentProvider
import Node
import JSON
import PostgreSQLProvider
final class District: Model {
  static var entity = "districts"
  static let foreignIdKey = "district"
  static let idKey = "id"
  var district : String
  let storage = Storage()
  init(district: String) {
        self.district = district
  }
  init(row: Row) throws {
        district = try row.get("district")
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("district", district)
        return row
  }
}
extension District: Preparation {
  static func prepare(_ database: Database) throws {
      try database.create(self) { data in
          data.id()
          data.string("district")
    }
  }
  static func revert(_ database: Database) throws {
      try database.delete(self)
  }
}
extension District: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("district", district)
        return node
    }
}
extension District: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("district", district)
        return json
    }
}
extension District {
    var colleges: Children<District, College> {
        return children()
    }
}
