import EventKit
import struct UIKit.CGFloat

enum SortMode: CaseIterable {
    case deadline
    case course
    case name
    
    var title: String {
        switch self {
        case .deadline: return "Deadline"
        case .course: return "Course"
        case .name: return "Name"
        }
    }
}

enum FilterMode: CaseIterable {
    case dueToday
    case dueTomorrow
    case dueThisWeek
    case byCourse
    
    var title: String {
        switch self {
        case .dueToday: return "Assignments due today"
        case .dueTomorrow: return "Assignments due tomorrow"
        case .dueThisWeek: return "Assignments due this week"
        case .byCourse: return "Assignments for course..."
        }
    }
}

protocol HWTaskListModelDelegate: class {
    func dataChanged()
    func courseFilterAlert()
}

final class HWTaskListModel {
    private let homeworkPersistence: HomeworkTaskPersistence
    
    private(set) var displayedTasks: [HomeworkTask] = [] // tasks currently being displayed
    var storedTasks: [HomeworkTask] {
        // retrieve homework tasks form core data
        // updated when tasks are saved to or deleted from persistence
        return homeworkPersistence.homeworkTasks.sorted(by: { $0.deadline < $1.deadline })
    }
    
    var reminderList: [EKReminder] = []
    
    let rowHeight: CGFloat = 70.0
    
    private weak var delegate: HWTaskListModelDelegate?
    
    // number of tasks being displayed
    var count: Int { return displayedTasks.count }
    
    init(delegate: HWTaskListModelDelegate, persistence: HomeworkTaskPersistence) {
        self.delegate = delegate
        self.homeworkPersistence = persistence
        
        displayedTasks = storedTasks // all tasks display by default
    }
}

extension HWTaskListModel {
    // Returns the displayed task at the given index
    func homeworkTask(atIndex index: Int) -> HomeworkTask? {
        return displayedTasks[index]
    }
    
    func sortList(by sortMode: SortMode) {
        switch sortMode {
        case .deadline: displayedTasks.sort(by: { $0.deadline < $1.deadline })
        case .course: displayedTasks.sort(by: { $0.course < $1.course && $0.deadline < $1.deadline })
        case .name: displayedTasks.sort(by: { $0.name < $1.name })
        }
        
        delegate?.dataChanged()
    }
    
    func filterList(by filterMode: FilterMode) {
        switch filterMode {
        case .dueToday:
            displayedTasks = getTasks(for: Date())
        case .dueTomorrow:
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                 displayedTasks = getTasks(for: tomorrow)
            }
        case .dueThisWeek:
            if let aWeekFromToday = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
                displayedTasks = displayedTasks.filter {
                    $0.deadline > Date() && $0.deadline < aWeekFromToday
                }
            }
        case .byCourse:
            delegate?.courseFilterAlert()
        }
        delegate?.dataChanged()
    }
    
    func filterByCourse(_ course: String) {
        displayedTasks = displayedTasks.filter { $0.course == course }
        delegate?.dataChanged()
    }
    
    // Retrieve all homework tasks due on a given date
    func getTasks(for date: Date) -> [HomeworkTask] {
        // get date components
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        let tasksForDate = displayedTasks.filter { task in
            let deadlineComponents = calendar.dateComponents([.day, .month, .year], from: task.deadline)
            
            return deadlineComponents == dateComponents
        }
        
        return tasksForDate
    }
    
    func searchList(searchText: String) {
        guard !searchText.isEmpty else {
            displayedTasks = storedTasks
            delegate?.dataChanged()
            return
        }
        
        displayedTasks = storedTasks.filter { task in
            task.name.lowercased().contains(searchText.lowercased()) || task.course.lowercased().contains(searchText.lowercased()) || task.taskDescription?.lowercased().contains(searchText.lowercased()) ?? false
        }
        delegate?.dataChanged()
    }
    
    func delete(at index: Int) {
        let taskToDelete: HomeworkTask = displayedTasks[index]
        homeworkPersistence.delete(homeworkTask: taskToDelete)
        displayedTasks.remove(at: index)
    }
}

extension HWTaskListModel: HWTaskCreationModelDelegate {
    func save(homeworkTask: HomeworkTask) {
        if let existingTaskIndex = storedTasks.firstIndex(where: { $0.id == homeworkTask.id }) {
            homeworkPersistence.delete(homeworkTask: storedTasks[existingTaskIndex])
            displayedTasks[existingTaskIndex] = homeworkTask
        } else {
            displayedTasks.append(homeworkTask)
        }
        
        homeworkPersistence.save(homeworkTask: homeworkTask)
        
        // refresh the data in the view controller
        delegate?.dataChanged()
    }
}
