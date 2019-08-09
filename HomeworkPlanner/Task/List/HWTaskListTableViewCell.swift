import UIKit

final class HWTaskListTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    // include an alarm indicator
    
    private(set) var homeworkTask: HomeworkTask!
    
    func setup(with homeworkTask: HomeworkTask) {
        print("Setting up cell for \(homeworkTask.name)")
        self.homeworkTask = homeworkTask
        
        nameLabel.text = homeworkTask.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let deadlineString = dateFormatter.string(from: homeworkTask.deadline)
        
        detailLabel.text = "\(homeworkTask.course)\nDue \(deadlineString)"
        
        // set alarm indicator
    }
}
