import UIKit

protocol HWTaskCalendarModelDelegate: class {
    
}

final class HWTaskCalendarModel {
    private(set) var homeworkTasks: [HomeworkTask] = []
    
    //private weak var delegate: HWTaskCalendarModelDelegate?
    
    init(homeworkTasks: [HomeworkTask]) {
        //self.delegate = delegate
        self.homeworkTasks = homeworkTasks
    }
    
    // Retrieve all homework tasks due on a given date
    private func getTasks(for date: Date) -> [HomeworkTask] {
        // get date components
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        let tasksForDate = homeworkTasks.filter { task in
            let deadlineComponents = calendar.dateComponents([.day, .month, .year], from: task.deadline)
            
            return deadlineComponents == dateComponents
        }
        
        return tasksForDate
    }
    
    func configureTasksDueLabel(for date: Date) -> String? {
        let tasksDue = getTasks(for: date)
        let taskStrings = tasksDue.map { $0.name }
        
        var labelText = ""
        for string in taskStrings {
            labelText.append("\(string)\n")
        }
        
        if !labelText.isEmpty {
            return labelText
        } else { return nil }
    }
    
    func alarmExists(for date: Date) -> Bool {
        // get date components
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        for task in homeworkTasks {
            if let alarmDate = task.alarmDate {
                let alarmDateComponents = calendar.dateComponents([.day, .month, .year], from: alarmDate)
                if alarmDateComponents == dateComponents {
                    return true
                }
            }
        }
        return false
    }
}
