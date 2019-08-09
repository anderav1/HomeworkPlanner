import UIKit

final class CourseCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

final class CourseListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCourseTextField: UITextField!
    
    private var model: CourseListModel!
}

extension CourseListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = CourseListModel(delegate: self, persistence: HomeworkTaskPersistence())
        
        addCourseTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = "My Courses"
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    func setup(model: CourseListModel) {
        self.model = model
    }
}

extension CourseListViewController: CourseListModelDelegate {
    func dataChanged() {
        tableView.reloadData()
    }
}

extension CourseListViewController: UITableViewDelegate {
    // Swiping a table cell will trigger delete in editing mode
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
}

extension CourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.courseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
        
        // set up the cell
        cell.titleLabel.text = model.courseList[indexPath.row]
        
        return cell
    }
}

extension CourseListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let newCourse = textField.text, !newCourse.isEmpty {
            model.add(course: newCourse)
        }
        textField.text = ""
        dataChanged()
        return true
    }
}
