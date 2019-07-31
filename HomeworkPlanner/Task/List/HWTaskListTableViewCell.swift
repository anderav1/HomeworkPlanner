import UIKit

final class HWTaskListTableViewCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var courseLabel: UILabel!
    @IBOutlet private weak var deadlineLabel: UILabel!
    // include a reminder indicator
    
    private(set) var homeworkTask: HomeworkTask!
    
    func setup(with homeworkTask: HomeworkTask) {
        self.homeworkTask = homeworkTask
        
        nameLabel.text = homeworkTask.name
        courseLabel.text = homeworkTask.course
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let deadlineString = dateFormatter.string(from: homeworkTask.deadline)
        deadlineLabel.text = "Due \(deadlineString)"
        
        // set reminder indicator
    }
}
