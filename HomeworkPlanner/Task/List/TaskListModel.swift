import EventKit
import struct UIKit.CGFloat

protocol HWTaskListModelDelegate: class {
    func dataRefreshed()
}

final class HWTaskListModel {
    //private let hwListPersistence:
    private var homeworkTasks: [HomeworkTask]
    private(set) var eventStore: EKEventStore
    
    let rowHeight: CGFloat = 70.0
    
    private weak var delegate: HWTaskListModelDelegate?
    
    var count: Int { return homeworkTasks.count }
    
    init(delegate: HWTaskListModelDelegate) {
        self.delegate = delegate
        
    }
}

extension HWTaskListModel {
    func homeworkTask(atIndex index: Int) -> HomeworkTask? {
        return homeworkTasks[index]
    }
}

extension HWTaskListModel: HWTaskCreationModelDelegate {
    var calendar: EKCalendar {
        get {
            <#code#>
        }
        set {
            <#code#>
        }
    }
    
    func save(homeworkTask: HomeworkTask) {
        <#code#>
    }
}
