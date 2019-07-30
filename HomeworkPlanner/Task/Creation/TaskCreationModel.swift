import EventKit
import Foundation

protocol HWTaskCreationModelDelegate: class {
    func save(homeworkTask: HomeworkTask)
}

enum TimeUnit: String, CaseIterable {
    case minutes, hours, days
    
    var secondsPerUnit: Int {
        switch self {
        case .minutes: return 60
        case .hours: return 60 * 60
        case .days: return 60 * 60 * 24
        }
    }
}

final class HWTaskCreationModel {
    private(set) var homeworkTask: HomeworkTask
    
    let minReminderValue = 1.0
    let maxReminderValue = 60.0
    
    private var isEditing: Bool
    
    var titleText: String { return isEditing ? "Edit Assignment" : "New Assignment" }
    var buttonText: String { return isEditing ? "Update" : "Add" }
    
    private weak var delegate: HWTaskCreationModelDelegate?
    
    init(homeworkTask: HomeworkTask, delegate: HWTaskCreationModelDelegate, isEditing: Bool) {
        self.homeworkTask = homeworkTask
        self.delegate = delegate
        self.isEditing = isEditing
    }
}

extension HWTaskCreationModel {
    func saveHomeworkTask(name: String, course: String, deadline: Date, description: String?, alert: HomeworkAlert?) {
        var homeworkTask: HomeworkTask {
            guard self.isEditing else {
                // new homework task
                return HomeworkTask(name: name, course: course, deadline: deadline, description: description, alert: alert)
            }
            // copy existing task
            return self.homeworkTask.copyWith(name: name, course: course, deadline: deadline, description: description, alert: alert)
        }
        
        #warning("Save homeworkTask to core data")
    }
    
    func addReminder(homeworkTask: HomeworkTask, timeUnit: TimeUnit, timeBeforeDeadline: Int, eventStore: EKEventStore) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = homeworkTask.name
        //reminder.calendar = delegate?.calendar
        reminder.notes = homeworkTask.taskDescription
        
        let timeInterval = TimeInterval(timeUnit.secondsPerUnit * timeBeforeDeadline)
        let alarmDate = homeworkTask.deadline - timeInterval
        
        let alarm = EKAlarm(absoluteDate: alarmDate)
        reminder.addAlarm(alarm)
    }
}
