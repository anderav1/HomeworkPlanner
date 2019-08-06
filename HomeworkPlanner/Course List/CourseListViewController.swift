import UIKit

final class CourseListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCourseTextField: UITextField!
    
    private var model: CourseListModel!
}

extension CourseListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = CourseListModel(delegate: self, persistence: HomeworkTaskPersistence())
        
        navigationItem.title = "My Courses"
        navigationItem.rightBarButtonItem = editButtonItem
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath)
        
        // set up the cell
        cell.textLabel?.text = model.courseList[indexPath.row]
        
        return cell
    }
}

extension CourseListViewController {
    @IBAction func addCourse(_ sender: UITextField) {
        if let newCourse = sender.text, !newCourse.isEmpty {
            model.add(course: newCourse)
        }
    }
}

