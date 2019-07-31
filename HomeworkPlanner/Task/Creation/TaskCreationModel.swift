import EventKit
import Foundation

protocol HWTaskCreationModelDelegate: class {
    var eventStore: EKEventStore { get set }
    var calendar: EKCalendar { get set }
    
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
    func saveHomeworkTask(name: String, course: String, deadline: Date, description: String?) {
        let reminder = createReminder(name: name, notes: description)
        
        var homeworkTask: HomeworkTask {
            guard self.isEditing else {
                // new homework task
                return HomeworkTask(name: name, course: course, deadline: deadline, description: description, reminder: reminder)
            }
            // copy existing task
            return self.homeworkTask.copyWith(name: name, course: course, deadline: deadline, description: description, reminder: reminder)
        }
        
        #warning("Save homeworkTask to core data")
    }
    
    private func createReminder(name: String, notes: String?) -> EKReminder {
        let reminder = EKReminder(eventStore: delegate!.eventStore)
        reminder.title = name
        reminder.calendar = delegate?.calendar
        reminder.notes = notes
        
        return reminder
    }
    
    func addHomeworkAlarm(timeUnit: TimeUnit, timeBeforeDeadline: Int) {
        let timeInterval = TimeInterval(timeUnit.secondsPerUnit * timeBeforeDeadline)
        let alarmDate = homeworkTask.deadline - timeInterval
        
        let alarm = EKAlarm(absoluteDate: alarmDate)
        homeworkTask.reminder?.addAlarm(alarm)
    }
}
