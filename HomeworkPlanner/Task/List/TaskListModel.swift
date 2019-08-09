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
    
    private(set) var displayedHomeworkTasks: [HomeworkTask] = [] // tasks currently being displayed
    private var storedHomeworkTasks: [HomeworkTask] = [] // tasks saved in persistence, unsorted
    var allHomeworkTasks: [HomeworkTask] = [] // master list, sorted by deadline
    
    var reminderList: [EKReminder] = []
    
    let rowHeight: CGFloat = 70.0
    
    private weak var delegate: HWTaskListModelDelegate?
    
    var count: Int { return displayedHomeworkTasks.count }
    
    init(delegate: HWTaskListModelDelegate, persistence: HomeworkTaskPersistence) {
        self.delegate = delegate
        self.homeworkPersistence = persistence
        
        // retrieve homework tasks from persistence
        storedHomeworkTasks = persistence.homeworkTasks
        
        allHomeworkTasks = storedHomeworkTasks.sorted(by: { $0.deadline < $1.deadline })
        displayedHomeworkTasks = allHomeworkTasks // all tasks display by default
    }
}

extension HWTaskListModel {
    func homeworkTask(atIndex index: Int) -> HomeworkTask? {
        return displayedHomeworkTasks[index]
    }
    
    func sortList(by sortMode: SortMode) {
        switch sortMode {
        case .deadline: displayedHomeworkTasks.sort(by: { $0.deadline < $1.deadline })
        case .course: displayedHomeworkTasks.sort(by: { $0.course < $1.course && $0.deadline < $1.deadline })
        case .name: displayedHomeworkTasks.sort(by: { $0.name < $1.name })
        }
    }
    
    func searchList(searchText: String) {
        guard !searchText.isEmpty else {
            displayedHomeworkTasks = allHomeworkTasks
            delegate?.dataChanged()
            return
        }
        
        displayedHomeworkTasks = allHomeworkTasks.filter { task in
            task.name.lowercased().contains(searchText.lowercased()) || task.course.lowercased().contains(searchText.lowercased()) || task.taskDescription?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }
    
    func delete(at index: Int) {
        let taskToDelete: HomeworkTask = displayedHomeworkTasks[index]
        homeworkPersistence.delete(homeworkTask: taskToDelete)
        displayedHomeworkTasks.remove(at: index)
        
        // remove task from master list
    }
}

extension HWTaskListModel: HWTaskCreationModelDelegate {
    func save(homeworkTask: HomeworkTask) {
        if let existingTaskIndex = allHomeworkTasks.firstIndex(where: { $0.id == homeworkTask.id }) {
            homeworkPersistence.delete(homeworkTask: allHomeworkTasks[existingTaskIndex])
        }
        
        homeworkPersistence.save(homeworkTask: homeworkTask)
        
        // update the master list
        allHomeworkTasks = homeworkPersistence.homeworkTasks.sorted(by: { $0.deadline < $1.deadline })
    }
}
