import Vapor
import Fluent
import FluentProvider
import PostgreSQLProvider
final class Meeting: Model {
  static var entity = "meetings"
  var date : Int
  var month : String
  var year : Int
  var hour : Int
  var mins : Int
  var location : String
  var comments : String
  var recruit : Identifier?
  let storage = Storage()
  init(date: Int, month: String, year: Int, hour: Int, mins: Int, location: String, comments: String, recruit: Recruit) {
        self.recruit = recruit.id
        self.date = date
        self.month = month
        self.year = year
        self.hour = hour
        self.mins = mins
        self.location = location
        self.comments = comments
  }
  init(row: Row) throws {
        date = try row.get("date")
        month = try row.get("month")
        year = try row.get("year")
        hour = try row.get("hour")
        mins = try row.get("mins")
        location = try row.get("location")
        comments = try row.get("comments")
        recruit = try row.get(Recruit.foreignIdKey)
  }
  func makeRow() throws -> Row {
        var row = Row()
        try row.set("date", date)
        try row.set("month", month)
        try row.set("year", year)
        try row.set("hour", hour)
        try row.set("mins", mins)
        try row.set("location", location)
        try row.set("comments", comments)
        try row.set(Recruit.foreignIdKey, recruit)
        return row
  }
}
extension Meeting: Preparation {
  static func prepare(_ database: Database) throws {
        try database.create(self) { data in
            data.id()
            data.foreignId(for: Recruit.self)
            data.string("date")
            data.string("month")
            data.string("year")
            data.string("hour")
            data.string("mins")
            data.string("location")
            data.string("comments")
      }
    }
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
extension Meeting: NodeRepresentable {
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("id", id)
        try node.set("date", date)
        try node.set("month", month)
        try node.set("year", year)
        try node.set("hour", hour)
        try node.set("mins", mins)
        try node.set("location", location)
        try node.set("comments", comments)
        try node.set(Recruit.foreignIdKey, recruit)
        return node
    }
}
extension Meeting: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("recruit", Recruit.makeQuery().filter("id",recruit).first())
        try json.set("date", date)
        try json.set("month", month)
        try json.set("year", year)
        try json.set("hour", hour)
        try json.set("mins", mins)
        try json.set("location", location)
        try json.set("comments", comments)
        return json
    }
}
