import EventKit

final class HomeworkPlannerCalendar {
    let eventStore = EKEventStore()
    let homeworkCalendar: EKCalendar
    
    private weak var delegate: HWTaskListModelDelegate?
    
    init() {
        let homeworkCalendar = EKCalendar(for: .reminder, eventStore: eventStore)
        homeworkCalendar.title = "Homework Planner"
        
        homeworkCalendar.source = eventStore.sources.first(where: {
            $0.sourceType.rawValue == EKSourceType.local.rawValue
        })
        
        try? {
            self.eventStore.saveCalendar(homeworkCalendar, commit: true)
            UserDefaults.standard.set(homeworkCalendar.calendarIdentifier, forKey: "HomeworkPlannerCalendar")
        } else {
            delegate?.calendarDidNotSave()
        }
    }

}


