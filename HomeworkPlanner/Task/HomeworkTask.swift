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
    
    // Copy initializer
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

// Persistance functionality derived from the in-class persistence lectures
extension HomeworkTask {
    static func from(_ homeworkTaskEntities: [HomeworkTaskEntity]) -> [HomeworkTask] {
        return homeworkTaskEntities.compactMap { HomeworkTask.from($0) }
    }
    
    static func from(_ homeworkTaskEntity: HomeworkTaskEntity) -> HomeworkTask? {
        guard let id = homeworkTaskEntity.id, let name = homeworkTaskEntity.name, let course = homeworkTaskEntity.course, let deadline = homeworkTaskEntity.deadline, let taskDescription = homeworkTaskEntity.taskDescription, let reminderId = homeworkTaskEntity.reminderId else { return nil }
        
        return HomeworkTask(id: id, name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId)
    }
}
