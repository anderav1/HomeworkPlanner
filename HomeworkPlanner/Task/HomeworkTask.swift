import Foundation

struct HomeworkTask: Codable {
    let id: UUID
    let name: String
    let course: String
    let deadline: Date
    let taskDescription: String?
    let reminderId: String?
    let alarmSettings: AlarmSettings?
    
    var alarmDate: Date? {
        if let timeUnitRawValue = alarmSettings?.timeUnit, let timeUnit = TimeUnit(rawValue: timeUnitRawValue), let timeAmount = alarmSettings?.timeAmount {
            let timeInterval = TimeInterval(timeUnit.secondsPerUnit * timeAmount)
            return deadline - timeInterval
        } else { return nil }
    }
}

struct AlarmSettings: Codable {
    let timeUnit: String
    let timeAmount: Int
}

extension HomeworkTask {
    init(name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?, alarmSettings: AlarmSettings?) {
        id = UUID()
        
        self.name = name
        self.course = course
        self.deadline = deadline
        self.taskDescription = taskDescription
        self.reminderId = reminderId
        self.alarmSettings = alarmSettings
    }
    
    // Copy initializer
    //        init(id: UUID, name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?, alarmSettings: AlarmSettings?) {
//        self.id = id
//        self.name = name
//        self.course = course
//        self.deadline = deadline
//        self.taskDescription = taskDescription
//        self.reminderId = reminderId
//    }
    
    func copyWith(name: String, course: String, deadline: Date, taskDescription: String?, reminderId: String?, alarmSettings: AlarmSettings?) -> HomeworkTask {
        return HomeworkTask(id: self.id, name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId, alarmSettings: alarmSettings)
    }
}

extension HomeworkTask {
    static var defaultHomeworkTask: HomeworkTask {
        return HomeworkTask(id: UUID(), name: "New Assignment", course: "n/a", deadline: Date(), taskDescription: nil, reminderId: nil, alarmSettings: nil)
    }
}

// Persistance functionality derived from the in-class persistence lectures
extension HomeworkTask {
    static func from(_ homeworkTaskEntities: [HomeworkTaskEntity]) -> [HomeworkTask] {
        return homeworkTaskEntities.compactMap { HomeworkTask.from($0) }
    }
    
    static func from(_ homeworkTaskEntity: HomeworkTaskEntity) -> HomeworkTask? {
        guard let id = homeworkTaskEntity.id, let name = homeworkTaskEntity.name, let course = homeworkTaskEntity.course, let deadline = homeworkTaskEntity.deadline, let taskDescription = homeworkTaskEntity.taskDescription, let reminderId = homeworkTaskEntity.reminderId else { return nil }
        
        let alarmSettings: AlarmSettings?
        if let alarmSettingsData = homeworkTaskEntity.alarmSettings {
            alarmSettings = try? JSONDecoder().decode(AlarmSettings.self, from: alarmSettingsData)
        } else {
            alarmSettings = nil
        }
        
        return HomeworkTask(id: id, name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId, alarmSettings: alarmSettings)
    }
}
