import UIKit
import EventKit

final class HWTaskListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var eventStore: EKEventStore!
    
    private var model: HWTaskListModel!
}

extension HWTaskListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = HWTaskListModel(delegate: self, persistence: HomeworkTaskPersistence())
        navigationItem.title = "Assignment List"
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
