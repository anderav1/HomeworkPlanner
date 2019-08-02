import UIKit
import JTAppleCalendar

/* The calendar view of the app utilizes JTAppleCalendar, a third-party module for creating & designing custom calendar views. */

final class HWTaskCalendarViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension HWTaskCalendarViewController: JTACMonthViewDataSource {
    // configure the range of the calendar
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let today = Date()
        
        var oneYearLater = DateComponents()
        oneYearLater.year = 1
        
        var endDate = Calendar.current.date(byAdding: oneYearLater, to: today)
        
    }
}

extension HWTaskCalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        <#code#>
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        <#code#>
    }
}
