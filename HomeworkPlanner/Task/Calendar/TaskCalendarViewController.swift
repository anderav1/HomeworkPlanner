import UIKit
import JTAppleCalendar

/* The calendar view of the app utilizes JTAppleCalendar, a third-party module for creating & designing custom calendar views. */

final class DateCell: JTACDayCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tasksDueLabel: UILabel!
    @IBOutlet var alarmDotIndicator: UIView!
}

final class CalendarHeader: JTACMonthReusableView {
    @IBOutlet var monthLabel: UILabel!
}

final class HWTaskCalendarViewController: UIViewController {
    @IBOutlet private var calendarView: JTACMonthView!
    @IBOutlet var rightSwipeRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var leftSwipeRecognizer: UISwipeGestureRecognizer!
    
    private var model: HWTaskCalendarModel!
    
    var cellDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure scrolling & paging functionality
        calendarView.scrollDirection = .horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.showsHorizontalScrollIndicator = false
    }
    
    func setup(model: HWTaskCalendarModel) {
        self.model = model
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
        
        let endDate = Calendar.current.date(byAdding: oneYearLater, to: today) ?? Date()
        
        return ConfigurationParameters(startDate: today, endDate: endDate, generateInDates: .forAllMonths, generateOutDates: .tillEndOfGrid)
    }
}

extension HWTaskCalendarViewController: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    // Configure calendar header
    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "calendarHeader", for: indexPath) as! CalendarHeader
        header.monthLabel.text = formatter.string(from: range.start)
        
        return header
    }
}

extension HWTaskCalendarViewController {
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? DateCell else { return }
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, cellState: cellState)
        handleCellEvents(cell: cell, cellState: cellState)
    }
    
    private func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.green
            cell.tasksDueLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
            cell.tasksDueLabel.textColor = UIColor.gray
        }
    }
    
    private func handleCellEvents(cell: DateCell, cellState: CellState) {
        cell.tasksDueLabel.text = model.configureTasksDueLabel(for: cellState.date)
        cell.alarmDotIndicator.isHidden = !model.alarmExists(for: cellState.date)
    }
}

extension HWTaskCalendarViewController {
    // Swipe left to view the next month
    @IBAction private func nextMonth(_ sender: UISwipeGestureRecognizer) {
        calendarView.scrollToSegment(.next)
    }
    
    // Swipe right to view the previous month
    @IBAction private func previousMonth(_ sender: UISwipeGestureRecognizer) {
        calendarView.scrollToSegment(.previous)
    }
}
