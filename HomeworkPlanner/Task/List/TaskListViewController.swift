import UIKit
import EventKit

final class HWTaskListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    #warning("Should these variables be private?")
    var eventStore: EKEventStore!
    var homeworkReminders: [EKReminder]!
    
    private var model: HWTaskListModel!
}

extension HWTaskListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = HWTaskListModel(delegate: self)
        navigationItem.title = "Assignment List"
    }
    
    // app must request permissions & fetch data before view loads
    override func viewWillAppear(_ animated: Bool) {
        eventStore = EKEventStore()
        homeworkReminders = [EKReminder]()
        
        // the event store must request permission to access the device's reminders
        eventStore.requestAccess(to: .reminder) { (granted: Bool, error: Error?) -> Void in
            if granted {
                // fetch reminders
                let predicate = self.eventStore.predicateForReminders(in: nil)
                self.eventStore.fetchReminders(matching: predicate, completion: { (reminders: [EKReminder]?) -> Void in
                    self.homeworkReminders = reminders
                    DispatchQueue.main.async {
                        self.dataRefreshed()
                    }
                })
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
