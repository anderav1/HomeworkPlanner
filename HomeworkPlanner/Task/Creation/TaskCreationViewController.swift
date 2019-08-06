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
        
        alarmTimeUnitsField.addTarget(self, action: #selector(timeUnitsAlert), for: .touchUpInside)
        
        // configure alarm elements
        alarmStepper.minimumValue = model.minReminderValue
        alarmStepper.maximumValue = model.maxReminderValue
        alarmStepper.stepValue = 1.0
        alarmStepper.value = Double(model.homeworkTask.alarmSettings?.timeAmount ?? 0)
       
        let timeAmount = model.homeworkTask.alarmSettings?.timeAmount ?? 0
        alarmTimeAmountLabel.text = "\(timeAmount)"
        
        if let timeUnit = model.homeworkTask.alarmSettings?.timeUnit {
            alarmTimeUnitsField.text = "\(timeUnit)"
        } else {
            alarmTimeUnitsField.text = nil
        }
        
        addButton.setTitle(model.buttonText, for: .normal)
        navigationItem.title = model.titleText
        
        nameField.text = model.homeworkTask.name
        courseField.text = model.homeworkTask.course
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
    
    @IBAction private func addButtonTapped(_ sender: UIButton) {
        var alarmUnit: TimeUnit? = nil
        var alarmAmount: Int? = nil
        
        if alarmStepper.value != 0.0 && alarmTimeUnitsField.text != nil {
            alarmUnit = TimeUnit(rawValue: alarmTimeUnitsField.text!)
            alarmAmount = Int(alarmStepper.value)
        }
        
        model.saveHomeworkTask(name: nameField.text!, course: courseField.text!, deadline: datePicker.date, taskDescription: descriptionField.text, alarmUnit: alarmUnit, alarmAmount: alarmAmount)
        
        navigationController?.popViewController(animated: true)
    }
}
