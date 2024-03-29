import UIKit
import EventKit

final class HWTaskListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let eventStore: EKEventStore = EKEventStore()
    private var model: HWTaskListModel!
    
    private var menuIsVisible = false
    
    #warning("Other features to add: task priority")
}

extension HWTaskListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = HWTaskListModel(delegate: self, persistence: HomeworkTaskPersistence())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        navigationItem.title = "Assignments"
        navigationItem.rightBarButtonItem = editButtonItem
        
        menuStackView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if !menuStackView.isHidden {
            print("Closing menu")
            toggleMenu()
        }
        
        if let creationViewController = segue.destination as? HWTaskCreationViewController { // segue to task creation
            // inherit event store
            creationViewController.eventStore = self.eventStore
            
            let homeworkTask: HomeworkTask = sender as? HomeworkTask ?? .defaultHomeworkTask
            
            var taskExists: Bool {
                return sender is HomeworkTask
            }
            
            let hwTaskCreationModel = HWTaskCreationModel(homeworkTask: homeworkTask, delegate: model, eventStore: creationViewController.eventStore, isEditing: taskExists)
            creationViewController.setup(model: hwTaskCreationModel)
            
        } else if let courseListViewController = segue.destination as? CourseListViewController { // segue to course list
            let courseListModel = CourseListModel(delegate: courseListViewController, persistence: HomeworkTaskPersistence())
            courseListViewController.setup(model: courseListModel)
            
        } else if let calendarViewController = segue.destination as? HWTaskCalendarViewController { // segue to hw calendar
            let calendarModel = HWTaskCalendarModel(homeworkTasks: self.model.storedTasks)
            calendarViewController.setup(model: calendarModel)
        }
    }
}

extension HWTaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HWTaskCell", for: indexPath) as! HWTaskListTableViewCell
        cell.setup(with: model.homeworkTask(atIndex: indexPath.row)!)
        
        return cell
    }
}

extension HWTaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return model.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HWTaskListTableViewCell
        
        if !isEditing {
            performSegue(withIdentifier: "taskCreation", sender: cell.homeworkTask)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.delete(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
}

extension HWTaskListViewController: HWTaskListModelDelegate {
    func dataChanged() {
        tableView.reloadData()
    }
    
    func courseFilterAlert() {
        let alert: UIAlertController
        let courses = HomeworkTaskPersistence().courses
        if !courses.isEmpty {
            alert = UIAlertController(title: "Choose a course", message: nil, preferredStyle: .alert)
            for course in courses {
                let filterAction = UIAlertAction(title: course, style: .default) { (action) -> Void in
                    self.model.filterByCourse(course)
                }
                alert.addAction(filterAction)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
        } else {
            alert = UIAlertController(title: "You have no saved courses", message: "Save courses to your list through the menu", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        }
        self.present(alert, animated: true, completion: nil)
    }
}

extension HWTaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.searchList(searchText: searchText)
    }
}

// menu functions
extension HWTaskListViewController {
    // Clicking the menu button toggles the menu
    @IBAction private func menuButtonClicked(_ sender: UIBarButtonItem) {
        toggleMenu()
    }
    
    private func toggleMenu() {
        menuStackView.isHidden = !menuIsVisible
        
        // update the menuIsVisible bool
        menuIsVisible = !menuIsVisible
    }
    
    @IBAction private func sortList(_ sender: UIButton) {
        // close the menu
        toggleMenu()
        
        // trigger an alert to choose sort mode
        let alert = UIAlertController(title: "Sort list by...", message: nil, preferredStyle: .alert)
        
        // add an action for each sort mode
        SortMode.allCases.forEach { sortMode in
            let sortAction = UIAlertAction(title: sortMode.title, style: .default) { (action) -> Void in
                self.model.sortList(by: sortMode)
            }
            alert.addAction(sortAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func filterList(_ sender: UIButton) {
        toggleMenu()
        
        let alert = UIAlertController(title: "Filter list to...", message: nil, preferredStyle: .alert)
        
        FilterMode.allCases.forEach { filterMode in
            let filterAction = UIAlertAction(title: filterMode.title, style: .default) { (action) -> Void in
                self.model.filterList(by: filterMode)
            }
            alert.addAction(filterAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
