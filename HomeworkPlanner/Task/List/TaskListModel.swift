import EventKit

protocol HWTaskListModelDelegate: class {
    func dataRefreshed()
}

final class HWTaskListModel {
    //private let hwListPersistence:
    private var homeworkTasks: [HomeworkTask]
    private(set) var eventStore: EKEventStore
    
    private weak var delegate: HWTaskListModelDelegate?
    
    var count: Int { return homeworkTasks.count }
    
    init(delegate: HWTaskListModelDelegate) {
        self.delegate = delegate
        
    }
}
