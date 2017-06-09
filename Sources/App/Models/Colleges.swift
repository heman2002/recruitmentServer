import Vapor
import Fluent
import FluentProvider
import PostgreSQLProvider
final class College: Model {
  static var entity = "colleges"
  var college : String
  var district : Identifier?
  static let foreignIdKey = "college"
  let storage = Storage()
  init(district: District, college: String) {
        self.district = district.id
        self.college = college
  }
  init(row: Row) throws {
        district = try row.get(District.foreignIdKey)
        college = try row.get("college")
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("college", college)
        try row.set(District.foreignIdKey, district)
        return row
  }
}
extension College: Preparation {
  static func prepare(_ database: Database) throws {
        try database.create(self) { data in
            data.id()
            data.foreignId(for: District.self)
            data.string("college")
      }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension College: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("college", college)
        try node.set(District.foreignIdKey, district)
        return node
    }
}
extension College: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("district", District.makeQuery().filter("id",district).first())
        try json.set("college", college)
        try json.set("degrees", degrees)
        return json
    }
}
extension College {
    var degrees: Siblings<College, Degree, Pivot<College, Degree>> {
        return siblings()
    }
}

extension College: Hashable {
  var hashValue: Int {
    return self.college.hashValue
  }
}

func ==(lhs: College, rhs: College) -> Bool {
  return lhs.college == rhs.college
}
