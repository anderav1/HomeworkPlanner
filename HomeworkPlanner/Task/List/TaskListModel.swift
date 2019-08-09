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

protocol HWTaskListModelDelegate: class {
    func dataChanged()
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
    
    func searchList(searchText: String) {
        guard !searchText.isEmpty else {
            displayedTasks = storedTasks
            delegate?.dataChanged()
            return
        }
        
        displayedTasks = storedTasks.filter { task in
            task.name.lowercased().contains(searchText.lowercased()) || task.course.lowercased().contains(searchText.lowercased()) || task.taskDescription?.lowercased().contains(searchText.lowercased()) ?? false
        }
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
