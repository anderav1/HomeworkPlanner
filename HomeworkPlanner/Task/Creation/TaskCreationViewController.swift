import UIKit
import EventKit

class HWTaskCreationViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var deadlineField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var alarmStepper: UIStepper!
    @IBOutlet weak var alarmTimeAmountLabel: UILabel!
    @IBOutlet weak var alarmTimeUnitsField: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    private var datePicker: UIDatePicker!
    
    var eventStore: EKEventStore!
    
    private var model: HWTaskCreationModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure deadline date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = model.homeworkTask.deadline
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateValueChanged), for: .valueChanged)
        
        deadlineField.inputView = datePicker
        
        alarmTimeUnitsField.addTarget(self, action: #selector(timeUnitsAlert), for: .editingDidBegin)
        
        // configure alarm elements
        alarmStepper.minimumValue = model.minReminderValue
        alarmStepper.maximumValue = model.maxReminderValue
        alarmStepper.stepValue = 1.0
        alarmStepper.value = Double(model.homeworkTask.alarmSettings?.timeAmount ?? 0)
       
        let timeAmount = Int(alarmStepper.value)
        alarmTimeAmountLabel.text = "\(timeAmount)"
        
        if let timeUnit = model.homeworkTask.alarmSettings?.timeUnit {
            alarmTimeUnitsField.text = "\(timeUnit)"
        } else {
            alarmTimeUnitsField.text = nil
        }
        
        addButton.setTitle(model.buttonText, for: .normal)
        navigationItem.title = model.titleText
        
        nameField.text = model.homeworkTask.name
        if model.homeworkTask.course != "n/a" {
            courseField.text = model.homeworkTask.course
        }
        descriptionField.text = model.homeworkTask.taskDescription ?? ""
    }
}

extension HWTaskCreationViewController {
    func setup(model: HWTaskCreationModel) {
        self.model = model
    }
}

extension HWTaskCreationViewController {
    @objc private func dateValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        deadlineField.text = dateFormatter.string(from: datePicker.date)
    }
    
    // Configure time units alert
    @objc private func timeUnitsAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        // add time unit options
        TimeUnit.allCases.forEach { unit in
            let timeUnitOption = UIAlertAction(title: unit.rawValue, style: .default) { (action) -> Void in
                self.alarmTimeUnitsField.text = unit.rawValue
            }
            alert.addAction(timeUnitOption)
        }
        
        // display the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func alarmAmountStepper(_ sender: UIStepper) {
        alarmTimeAmountLabel.text = "\(Int(sender.value))"
    }
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        var alarmUnit: TimeUnit? = nil
        var alarmAmount: Int? = nil
        
        if alarmStepper.value != 0.0 && alarmTimeUnitsField.text != nil {
            alarmUnit = TimeUnit(rawValue: alarmTimeUnitsField.text!)
            alarmAmount = Int(alarmStepper.value)
        }
        
        // ensure access to reminders before saving
        let permissionStatus = EKEventStore.authorizationStatus(for: .reminder)
        switch permissionStatus {
        case .notDetermined:
            eventStore.requestAccess(to: .reminder, completion: { (granted: Bool, error: Error?) -> Void in
                if granted {
                    print("Access to reminders successfully granted.")
        
                    DispatchQueue.main.async { [weak self] in
                        if let name = self?.nameField.text, let course = self?.courseField.text, let deadline = self?.datePicker.date {
                            let taskDescription = self?.descriptionField.text
                            
                            self?.model.saveHomeworkTask(name: name, course: course, deadline: deadline, taskDescription: taskDescription, alarmUnit: alarmUnit, alarmAmount: alarmAmount)
                        }
                    }
                    self.navigationController?.popViewController(animated: true)
                    
                } else {
                    print("Homework Planner does not have permission to access reminders.")
        
                    self.permissionDeniedAlert()
                }
            })
            
        case .restricted, .denied:
            permissionDeniedAlert()
            
        case .authorized:
            // save the homework task
            model.saveHomeworkTask(name: nameField.text!, course: courseField.text ?? "n/a", deadline: datePicker.date, taskDescription: descriptionField.text, alarmUnit: alarmUnit, alarmAmount: alarmAmount)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension HWTaskCreationViewController {
    private func permissionDeniedAlert() {
        let alert = UIAlertController(title: "Homework Planner cannot access your calendar reminders", message: "Change this permission in your settings", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Close app", style: .default) { (action) -> Void in
            DispatchQueue.main.async {
                exit(0)
            }
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension HWTaskCreationViewController {
    @IBAction func selectCourseFromList(_ sender: UIButton) {
        let courses = HomeworkTaskPersistence().courses
        if !courses.isEmpty {
            let alert = UIAlertController(title: "Choose course", message: "Configure your course list in the menu under \"My Course List\"", preferredStyle: .alert)
            
            for course in courses {
                let action = UIAlertAction(title: course, style: .default) { (action) -> Void in
                    self.courseField.text = course
                }
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "You have not created a course list", message: "Configure your course list in the menu under \"My Course List\"", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
