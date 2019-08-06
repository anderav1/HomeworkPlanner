import UIKit
import EventKit

final class HWTaskListViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak var menuStackView: UIStackView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // menu buttons
    @IBOutlet weak var courseListButton: UIButton!
    @IBOutlet weak var newAssignmentButton: UIButton!
    @IBOutlet weak var sortListButton: UIButton!
    @IBOutlet weak var viewCalendarButton: UIButton!
    
    private var eventStore: EKEventStore!
    
    private var model: HWTaskListModel!
    
    private var menuIsVisible = false
    
    #warning("Other features to add: sort list, filter list, delete items, add task priority")
}

extension HWTaskListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = HWTaskListModel(delegate: self, persistence: HomeworkTaskPersistence())
        navigationItem.title = "Assignment List"
        
        // configure menu
        #warning("configure menu")
        menuStackView.isHidden = true
    }
    
    // the event store must request permission to access the device's reminders
    override func viewWillAppear(_ animated: Bool) {
        eventStore = EKEventStore()

        eventStore.requestAccess(to: .reminder) { (granted: Bool, error: Error?) -> Void in
            if granted {
                print("Access to reminders successfully granted.")
            } else {
                print("Homework Planner does not have permission to access reminders.")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let creationViewController = segue.destination as? HWTaskCreationViewController {
            // inherit event store
            creationViewController.eventStore = self.eventStore
            
            let homeworkTask: HomeworkTask = sender as? HomeworkTask ?? .defaultHomeworkTask
            
            var taskExists: Bool {
                return sender is HomeworkTask
            }
            
            let hwTaskCreationModel = HWTaskCreationModel(homeworkTask: homeworkTask, delegate: model, isEditing: taskExists)
            creationViewController.setup(model: hwTaskCreationModel)
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
        
        performSegue(withIdentifier: "HWTaskCreation", sender: cell.homeworkTask)
    }
}

extension HWTaskListViewController: HWTaskListModelDelegate {
    func dataRefreshed() {
        tableView.reloadData()
    }
}

extension HWTaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.searchList(searchText: searchText)
    }
}

extension HWTaskListViewController {
    // Clicking the menu button will toggle the menu
    @IBAction private func menuButtonClicked(_ sender: UIBarButtonItem) {
        menuStackView.isHidden = !menuIsVisible
        
        // update the menuIsVisible bool
        menuIsVisible = !menuIsVisible
    }
    
    @IBAction private func viewCourseList(_ sender: UIButton) {
        
    }
    
    @IBAction private func newAssignment(_ sender: UIButton) {
        
    }
    
    @IBAction private func sortList(_ sender: UIButton) {
        // trigger an alert to choose sort mode
    }
    
    @IBAction private func viewCalendar(_ sender: UIButton) {
        
    }
}
