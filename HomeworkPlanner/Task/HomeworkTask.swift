import Foundation

struct HomeworkAlert: Codable {
    let id: UUID
    let date: Date
    let text: String
}

struct HomeworkTask: Codable {
    let id: UUID
    let name: String
    let course: String
    let deadline: Date
    let description: String?
    let alert: HomeworkAlert?
}

extension HomeworkTask {
    init(name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) {
        id = UUID()
        
        self.name = name
        self.course = course
        self.deadline = deadline
        self.description = description
        self.alert = alert
    }
    
    // copy initializer
    init(id: UUID, name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) {
        self.id = id
        self.name = name
    }
}
