import EventKit // for generating reminders and alarms

struct HomeworkTask: Codable {
    let id: UUID
    let name: String
    let course: String
    let deadline: Date
    let taskDescription: String?
    let reminder: EKReminder    // must decode from reminder_id
    
    let hwCalendar = EKEventStore.calendar(withIdentifier: "Homework Planner")
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case course
        case deadline
        case taskDescription = "task_description"
        case reminder = "reminder_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(UUID.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        course = try values.decode(String.self, forKey: .course)
        deadline = try values.decode(Date.self, forKey: .deadline)
        taskDescription = try values.decodeIfPresent(String.self, forKey: .taskDescription)
        
        let reminderId = try values.decode(String.self, forKey: .reminder)
        reminder = calendarItem(withIdentifier: reminderId) as EKReminder
        //reminder = calendarItem(withIdentifier: reminderId) as EKReminder
    }
}

extension HomeworkTask {
    init(name: String, course: String, deadline: Date, description: String?, reminder: EKReminder) {
        id = UUID()
        
        self.name = name
        self.course = course
        self.deadline = deadline
        self.taskDescription = description
        self.reminder = reminder
    }
    
    // copy initializer
    //    init(id: UUID, name: String, course: String, deadline: Date, description: String?, reminder: EKReminder) {
//        self.id = id
//        self.name = name
//        self.course = course
//        self.deadline = deadline
//        self.taskDescription = description
//        self.reminder = reminder
//    }
    
    func copyWith(name: String, course: String, deadline: Date, description: String?, reminder: EKReminder) -> HomeworkTask {
        return HomeworkTask(id: self.id, name: name, course: course, deadline: deadline, taskDescription: description, reminder: reminder)
    }
}
