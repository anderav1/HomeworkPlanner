import EventKit
import struct UIKit.CGFloat

protocol HWTaskListModelDelegate: class {
    func dataRefreshed()
}

final class HWTaskListModel {
    private let homeworkPersistence: HomeworkTaskPersistence
    private(set) var eventStore: EKEventStore
    
    private(set) var displayedHomeworkTasks: [HomeworkTask] = [] // tasks currently being displayed
    private var storedHomeworkTasks: [HomeworkTask] = [] // tasks saved in persistence
    private var allHomeworkTasks: [HomeworkTask] = [] // all tasks
    
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
        displayedHomeworkTasks = allHomeworkTasks // all tasks are displayed by default
        
        for task in storedHomeworkTasks {
            
        }
    }
}

extension HWTaskListModel {
    func homeworkTask(atIndex index: Int) -> HomeworkTask? {
        return displayedHomeworkTasks[index]
    }
    
//    func sortList() {
//        // sort homework tasks by deadline
//        displayedHomeworkTasks.sort(by: { $0.deadline < $1.deadline })
//    }
}

extension HWTaskListModel: HWTaskCreationModelDelegate {
    func save(homeworkTask: HomeworkTask) {
        // save homework task to persistence
        homeworkPersistence.save(homeworkTask: homeworkTask)
        
        // update the master list
        allHomeworkTasks = homeworkPersistence.homeworkTasks.sorted(by: { $0.deadline < $1.deadline })
    }
}
