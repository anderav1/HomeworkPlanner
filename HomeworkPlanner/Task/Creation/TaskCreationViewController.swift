import UIKit
import EventKit

class HWTaskCreationViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var courseField: UITextField!
    @IBOutlet weak var deadlineField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var reminderStepper: UIStepper!
    @IBOutlet weak var reminderTimeAmountLabel: UILabel!
    @IBOutlet weak var reminderTimeUnitsLabel: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    private var datePicker: UIDatePicker!
    private var timeUnitPicker: UIPickerView!
    
    var eventStore: EKEventStore!
    
    var timeUnits: [TimeUnit] = []
    
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
        
        // configure time unit picker
        timeUnitPicker.delegate = self
        timeUnitPicker.dataSource = self
        
        // configure reminder stepper and labels
        reminderStepper.minimumValue = model.minReminderValue
        reminderStepper.maximumValue = model.maxReminderValue
        
        addButton.setTitle(model.buttonText, for: .normal)
        navigationItem.title = model.titleText
        
        for unit in TimeUnit.allCases { timeUnits.append(unit) }
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
}

// picker view functions
extension HWTaskCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeUnits.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeUnits[row].rawValue
    }
}
