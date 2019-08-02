import Foundation

struct HomeworkTask: Codable {
    let id: UUID
    let name: String
    let course: String
    let deadline: Date
    let taskDescription: String?
    let reminderId: String?
}

extension HomeworkTask {
    init(name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?) {
        id = UUID()
        
        self.name = name
        self.course = course
        self.deadline = deadline
        self.taskDescription = taskDescription
        self.reminderId = reminderId
    }
    
    // copy initializer
//        init(id: UUID, name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?) {
//        self.id = id
//        self.name = name
//        self.course = course
//        self.deadline = deadline
//        self.taskDescription = taskDescription
//        self.reminderId = reminderId
//    }
    
    func copyWith(name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?) -> HomeworkTask {
        return HomeworkTask(id: self.id, name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId)
    }
}

extension HomeworkTask {
    static var defaultHomeworkTask: HomeworkTask {
        return HomeworkTask(id: UUID(), name: "", course: "", deadline: Date(), taskDescription: nil, reminderId: nil)
    }
}
