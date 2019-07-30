import EventKit // for generating events and alarms

class HomeworkAlert: EKReminder, Codable {
    
    //func addAlarm(_ alarm: EKAlarm)
    //removeAlarm(_:)
    
    init(eventStore: EKEventStore) {
    }
    
/* EKReminder properties:
     enum EKReminderPriority // case high, low, medium, none
     var priority: Int
     var startDateComponents: DateComponents?
     var dueDateComponents: DateComponents?
     var isCompleted: Bool
     var completionDate: Date?
 */
}

struct HomeworkTask: Codable {
    let id: UUID
    let name: String
    let course: String
    let deadline: Date
    let taskDescription: String?
    let alert: EKReminder?
}

extension HomeworkTask {
    init(name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) {
        id = UUID()
        
        self.name = name
        self.course = course
        self.deadline = deadline
        self.taskDescription = description
        self.alert = alert
    }
    
    // copy initializer
//    init(id: UUID, name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) {
//        self.id = id
//        self.name = name
//        self.course = course
//        self.deadline = deadline
//        self.taskDescription = description
//        self.alert = alert
//    }
    
    func copyWith(name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) -> HomeworkTask {
        return HomeworkTask(id: self.id, name: name, course: course, deadline: deadline, taskDescription: description, alert: alert)
    }
}
