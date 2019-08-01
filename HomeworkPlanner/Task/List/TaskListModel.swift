import EventKit
import struct UIKit.CGFloat

protocol HWTaskListModelDelegate: class {
    func dataRefreshed()
}

final class HWTaskListModel {
    //private let hwListPersistence:
    private var homeworkTasks: [HomeworkTask]
    private(set) var eventStore: EKEventStore
    // see https://www.andrewcbancroft.com/2015/06/17/creating-calendars-with-event-kit-and-swift/
    
    let rowHeight: CGFloat = 70.0
    
    private weak var delegate: HWTaskListModelDelegate?
    
    var count: Int { return homeworkTasks.count }
    
    init(delegate: HWTaskListModelDelegate) {
        self.delegate = delegate
        
        #warning("retrieve homework tasks from persistence")
    }
}

extension HWTaskListModel {
    func homeworkTask(atIndex index: Int) -> HomeworkTask? {
        return homeworkTasks[index]
    }
    
    func sort() {
        homeworkTasks.sort(by: { $0.deadline < $1.deadline })
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
        #warning("save homework task to persistence")
    }
}
