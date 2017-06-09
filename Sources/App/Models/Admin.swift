import Vapor
import Fluent
import FluentProvider
import PostgreSQLProvider
final class Admin: Model {
  static var entity = "admins"
  var name : String
  var email_id : String
  var password : String
  var permission : String
  let storage = Storage()
  init(name: String, email_id: String, password: String, permission: String) {
        self.name = name
        self.email_id = email_id
        self.password = password
        self.permission = permission
  }
  init(row: Row) throws {
        name = try row.get("name")
        email_id = try row.get("email_id")
        password = try row.get("password")
        permission = try row.get("permission")
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email_id", email_id)
        try row.set("password", password)
        try row.set("permission", permission)
        return row
  }
}
extension Admin: Preparation {
  static func prepare(_ database: Database) throws {
        try database.create(self) { data in
            data.id()
            data.string("name")
            data.string("email_id")
            data.string("password")
            data.string("permission")
      }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension Admin: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("email_id", email_id)
        try node.set("password", password)
        try node.set("permission", permission)
        return node
    }
}
extension Admin: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email_id", email_id)
        try json.set("password", password)
        try json.set("permission", permission)
        return json
    }
}
