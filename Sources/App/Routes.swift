import Vapor
import Sessions

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        post("addDistrict") { req in
          guard let newDistrict = req.data["district"]?.string else {
            throw Abort.badRequest
          }
          let disQuery = try District.makeQuery().filter("district", newDistrict).all()
          if (disQuery.count != 0) {
            return "district already exists"
          }
          let district = District(district: newDistrict)
          try district.save()
          return try JSON(node: District.all())
        }

        post("addCollege") { req in
          guard let newCollege = req.data["college"]?.string else {
            throw Abort.badRequest
          }
          guard let newDistrict = req.data["district"]?.string else {
            throw Abort.badRequest
          }
          guard let disQuery = try District.makeQuery().filter("district", newDistrict).first() else {
            return "district does not exist"
          }
          let college = College(district: disQuery,college: newCollege)
          try college.save()
          return try JSON(node: College.all())
        }

        post("addDegree") { req in
          guard let newDegree = req.data["degree"]?.string else {
            throw Abort.badRequest
          }
          let degQuery = try Degree.makeQuery().filter("degree", newDegree).all()
          if (degQuery.count != 0) {
            return "degree already exists"
          }
          let degree = Degree(degree: newDegree)
          try degree.save()
          return try JSON(node: Degree.all())
        }

        post("addCollegeDegree") { req in
          guard let newDegree = req.data["degree"]?.string else {
            throw Abort.badRequest
          }
          guard let newCollege = req.data["college"]?.string else {
            throw Abort.badRequest
          }
          let degQuery = try Degree.makeQuery().filter("degree", newDegree).first()
          if (degQuery == nil) {
            return "degree does not exist"
          }
          let degree = degQuery!
          let collQuery = try College.makeQuery().filter("college", newCollege).first()
          if (collQuery == nil) {
            return "college does not exist"
          }
          let degrees = try collQuery?.degrees.all()
          let filteredDegrees = degrees?.filter{ $0.degree == newDegree}
          if (filteredDegrees?.count != 0) {
            return "degree exists in college"
          }
          try collQuery?.degrees.add(degree)
          return try JSON(node: collQuery?.degrees.all())
        }

        post("addDepartment") { req in
          guard let newDepartment = req.data["department"]?.string else {
            throw Abort.badRequest
          }
          guard let newDegree = req.data["degree"]?.string else {
            throw Abort.badRequest
          }
          guard let degQuery = try Degree.makeQuery().filter("degree", newDegree).first() else {
            return "degree does not exist"
          }
          let department = Department(degree: degQuery,department: newDepartment)
          try department.save()
          return try JSON(node: Department.all())
        }

        get("all") { req in
            return try JSON(node: Recruit.all())
        }


        get("selected") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","selected").all())
        }

        get("applied") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","applied").all())
        }

        get("meeting") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","meeting").all())
        }

        get("calldrop1") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","calldrop1").all())
        }

        get("calldrop2") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","calldrop2").all())
        }

        get("waiting") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","waiting").all())
        }

        get("rejected") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","rejected").all())
        }

        get("fake") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","fake").all())
        }

        get("terminated") { req in
            return try JSON(node: Recruit.makeQuery().filter("status","terminated").all())
        }

        get("colleges") { req in
            return try JSON(node: College.all())
        }

        post("signin") { request in
          guard let name = request.data["name"]?.string else {
            throw Abort.badRequest
          }
          guard let email_id = request.data["email_id"]?.string else {
            throw Abort.badRequest
          }
          guard let password = request.data["password"]?.string else {
            throw Abort.badRequest
          }
          var admin = Admin(
                        name : name,
                        email_id : email_id,
                        password : password,
                        permission : "any"
                        )
          let posQuery = try Admin.makeQuery().filter("email_id", email_id).all()
          if posQuery.count != 0 {
              return "data not allowed"
          }
          try admin.save()
          return try JSON(node: Admin.all())
        }

        post("remember") { req in
            guard let email_id = req.data["email_id"]?.string else {
                throw Abort.badRequest
            }

            guard let password = req.data["password"]?.string else {
                throw Abort.badRequest
            }
            guard let loginQuery = try Admin.makeQuery().filter("email_id", email_id).filter("password",password).first() else {
                return "login unsuccessful"
            }

            return try JSON(node: loginQuery)
        }


        post("clear") { request in
          guard let id = request.data["id"]?.string else {
            throw Abort.badRequest
          }
          guard let changeQuery = try Recruit.makeQuery().filter("id", id).first() else {
            throw Abort.badRequest
          }
          try changeQuery.delete()
          return "deleted"
        }

        post("changestatus") { request in
          guard let id = request.data["id"]?.string else {
            throw Abort.badRequest
          }
          guard let status = request.data["status"]?.string else {
            throw Abort.badRequest
          }
          guard let changeQuery = try Recruit.makeQuery().filter("id", id).first() else {
            throw Abort.badRequest
          }
          changeQuery.status = status
          try changeQuery.save()
          return try JSON(node: changeQuery)
        }

        post("data") { request in
          guard let district = request.data["district"]?.string else {
            throw Abort.badRequest
          }

          guard let degree = request.data["degree"]?.string else {
            throw Abort.badRequest
          }

          guard let department = request.data["department"]?.string else {
            throw Abort.badRequest
          }
          let session = try request.assertSession()
          try session.data.set("district", district)
          try session.data.set("degree", degree)
          try session.data.set("department", department)
          return "data received"
        }

        get("college") { req in
          let session = try req.assertSession()
            guard let district = session.data["district"]?.string else {
                throw Abort.badRequest
            }
            guard let degree = session.data["degree"]?.string else {
                throw Abort.badRequest
            }

            guard let disQuery = try District.makeQuery().filter("district", district).first() else {
              throw Abort.badRequest
            }

            let discolleges = try disQuery.colleges.all()
            guard let degQuery = try Degree.makeQuery().filter("degree", degree).first() else {
              throw Abort.badRequest
            }
            let degcolleges = try degQuery.colleges.all()
            let set1:Set<College> = Set(discolleges)
            let set2:Set<College> = Set(degcolleges)
            let colleges = set1.intersection(set2)
            return try JSON(node: discolleges)
        }

        post("temp") { request in
          let session = try request.assertSession()
          guard let year = request.data["year"]?.string else {
            throw Abort.badRequest
          }

          guard let year_of_joining = request.data["year_of_joining"]?.string else {
            throw Abort.badRequest
          }

          guard let college = request.data["college"]?.string else {
            throw Abort.badRequest
          }

          try session.data.set("year", year)
          try session.data.set("year_of_joining", year_of_joining)
          try session.data.set("college", college)
          return "data received"
        }


        post("application") { request in
            let session = try request.assertSession()
            guard let name = request.data["name"]?.string else {
              throw Abort.badRequest
            }
            guard let email_id = request.data["email_id"]?.string else {
              throw Abort.badRequest
            }
            guard let contact_no = request.data["contact_no"]?.int else {
              throw Abort.badRequest
            }
            guard let sop = request.data["sop"]?.string else {
              throw Abort.badRequest
            }
            guard let newDepartment = session.data["department"]?.string else {
                throw Abort.badRequest
            }
            guard let year = session.data["year"]?.string else {
                throw Abort.badRequest
            }
            guard let year_of_joining = session.data["year_of_joining"]?.int else {
                throw Abort.badRequest
            }
            guard let newCollege = session.data["college"]?.string else {
                throw Abort.badRequest
            }
            let department = try Department.makeQuery().filter("department", newDepartment).first()
            let college = try College.makeQuery().filter("college", newCollege).first()
            let recruit = Recruit(name : name,
                          emailId : email_id,
                          contactNo : contact_no,
                          year : year,
                          yearOfJoining : year_of_joining,
                          sop : sop,
                          status : "applied",
                          college : college!,
                          department : department!)
            let posQuery = try Recruit.makeQuery().filter("college", college).filter("department", department).filter("year", year).filter("year_of_joining", year_of_joining).filter("status", "selected").all()
            if posQuery.count != 0 {
                recruit.status = "noavailability"
                try recruit.save()
                return "data not allowed"
            }
            try recruit.save()
            return try JSON(node: Recruit.all())
        }

        post("scheduled") { request in
          guard let id = request.data["id"]?.string else {
            throw Abort.badRequest
          }
          guard let status = request.data["status"]?.string else {
            throw Abort.badRequest
          }
          guard let date = request.data["date"]?.int else {
            throw Abort.badRequest
          }
          guard let month = request.data["month"]?.string else {
            throw Abort.badRequest
          }
          guard let year = request.data["year"]?.int else {
            throw Abort.badRequest
          }
          guard let hour = request.data["hour"]?.int else {
            throw Abort.badRequest
          }
          guard let mins = request.data["mins"]?.int else {
            throw Abort.badRequest
          }
          guard let location = request.data["location"]?.string else {
            throw Abort.badRequest
          }
          guard let comments = request.data["comments"]?.string else {
            throw Abort.badRequest
          }
          guard let changeQuery = try Recruit.makeQuery().filter("id", id).first() else {
            throw Abort.badRequest
          }
          changeQuery.status = status
          try changeQuery.save()
          let meeting = Meeting(date: date, month: month, year: year, hour: hour, mins: mins, location: location, comments: comments, recruit: changeQuery)
          try meeting.save()
          return try JSON(node: Meeting.all())
        }

        try resource("posts", PostController.self)
    }
}
