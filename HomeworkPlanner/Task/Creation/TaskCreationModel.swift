import EventKit
import Foundation

protocol HWTaskCreationModelDelegate: class {
    var eventStore: EKEventStore { get }
    
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
    let buttonText = "Save"
    
    private weak var delegate: HWTaskCreationModelDelegate?
    
    init(homeworkTask: HomeworkTask, delegate: HWTaskCreationModelDelegate, isEditing: Bool) {
        self.homeworkTask = homeworkTask
        self.delegate = delegate
        self.isEditing = isEditing
    }
}

extension HWTaskCreationModel {
    // Save the homework task object to core data
    func saveHomeworkTask(name: String, course: String, deadline: Date, taskDescription: String?, withAlarm: Bool) {
        // get or create the corresponding reminder for homeworkTask
        let reminder: EKReminder
        if isEditing { // a reminder already exists for the homework task
            reminder = fetchReminder()
        } else { // create a new reminder
            reminder = createReminder(name: name, notes: taskDescription)
        }
        let reminderId = reminder.calendarItemIdentifier
        
        var homeworkTask: HomeworkTask {
            guard self.isEditing else {
                // new homework task
                return HomeworkTask(name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId)
            }
            // copy existing task
            return self.homeworkTask.copyWith(name: name, course: course, deadline: deadline, taskDescription: taskDescription, reminderId: reminderId)
        }
        
        delegate?.save(homeworkTask: homeworkTask)
    }
    
    // Fetch the corresponding reminder for an existing homework task
    func fetchReminder() -> EKReminder {
        return delegate?.eventStore.calendarItem(withIdentifier: homeworkTask.reminderId!) as! EKReminder
    }
    
    // Create a reminder corresponding to the homework task
    private func createReminder(name: String, notes: String?) -> EKReminder {
        let reminder = EKReminder(eventStore: delegate!.eventStore)
        reminder.title = name
        reminder.calendar = delegate?.eventStore.defaultCalendarForNewReminders()
        reminder.notes = notes
        
        do {
            try delegate?.eventStore.save(reminder, commit: true)
            
            print("Successfully saved reminder for \(homeworkTask.name)")
        } catch {
            print("Error: could not save reminder for \(homeworkTask.name)")
        }
        
        return reminder
    }
    
    // Add an alarm to the corresponding calendar reminder
    private func addHomeworkAlarm(timeUnit: TimeUnit, timeBeforeDeadline: Int) {
        let reminder = fetchReminder()
        
        // if the homework task is being edited, make sure it will only have the most recently set alarm
        if isEditing && reminder.hasAlarms {
            // delete any previously set alarm
            for alarm in reminder.alarms! {
                reminder.removeAlarm(alarm)
            }
        }
        
        // configure the new alarm
        let timeInterval = TimeInterval(timeUnit.secondsPerUnit * timeBeforeDeadline)
        let alarmDate = homeworkTask.deadline - timeInterval
        
        let alarm = EKAlarm(absoluteDate: alarmDate)
        
        reminder.addAlarm(alarm)
        
        do {
            try delegate?.eventStore.commit()
        } catch {
            print("Error: Could not save reminder alarm to event store.")
        }
    }
    
    func getAlarmValues() -> (stepperValue: Double, unit: TimeUnit) {
        #warning("write this function")
    }
}
