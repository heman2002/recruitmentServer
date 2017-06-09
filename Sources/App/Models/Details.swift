import Vapor
import Fluent
import FluentProvider
import PostgreSQLProvider
final class Recruit: Model {
  static var entity = "recruits"
  static let foreignIdKey = "recruit"
  let storage = Storage()
  var name : String
  var email_id : String
  var contact_no : Int
  var year : String
  var year_of_joining : Int
  var sop : String
  var status : String
  var college : Identifier?
  var department : Identifier?
  init(name: String, emailId: String, contactNo: Int, year: String, yearOfJoining: Int, sop: String, status: String, college: College, department: Department) {
    self.name = name
    self.email_id = emailId
    self.contact_no = contactNo
    self.college = college.id
    self.year = year
    self.year_of_joining = yearOfJoining
    self.department = department.id
    self.sop = sop
    self.status = status
  }
  init(row: Row) throws {
        name = try row.get("name")
        email_id = try row.get("email_id")
        contact_no = try row.get("contact_no")
        year = try row.get("year")
        year_of_joining = try row.get("year_of_joining")
        sop = try row.get("sop")
        status = try row.get("status")
        college = try row.get(College.foreignIdKey)
        department = try row.get(Department.foreignIdKey)
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("email_id", email_id)
        try row.set("contact_no", contact_no)
        try row.set("year", year)
        try row.set("year_of_joining", year_of_joining)
        try row.set("sop", sop)
        try row.set("status", status)
        try row.set(College.foreignIdKey, college)
        try row.set(Department.foreignIdKey, department)
        return row
  }
}
extension Recruit: Preparation {
  static func prepare(_ database: Database) throws {
        try database.create(self) { data in
            data.id()
            data.foreignId(for: Department.self)
            data.foreignId(for: College.self)
            data.string("name")
            data.string("email_id")
            data.int("contact_no")
            data.string("year")
            data.int("year_of_joining")
            data.string("sop")
            data.string("status")
      }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension Recruit: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("name", name)
        try node.set("email_id", email_id)
        try node.set("contact_no", contact_no)
        try node.set("year", year)
        try node.set("year_of_joining", year_of_joining)
        try node.set("sop", sop)
        try node.set("status", status)
        try node.set(College.foreignIdKey, college)
        try node.set(Department.foreignIdKey, department)
        return node
    }
}
extension Recruit: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("college", College.makeQuery().filter("id",college).first())
        try json.set("department", Department.makeQuery().filter("id",department).first())
        try json.set("name", name)
        try json.set("email_id", email_id)
        try json.set("contact_no", contact_no)
        try json.set("year", year)
        try json.set("year_of_joining", year_of_joining)
        try json.set("sop", sop)
        try json.set("status", status)
        return json
    }
}
