//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
//import FirebaseFirestore

class EditEventViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var table: UITableView!
    
    let datePickerStartDate = UIDatePicker()
    let datePickerStartTime = UIDatePicker()
    let datePickerEndDate = UIDatePicker()
    let datePickerEndTime = UIDatePicker()
    let datePickerReminderDate = UIDatePicker()
    let datePickerReminderTime = UIDatePicker()
    
    var saveButton = UIBarButtonItem()
    
    var databaseManager = EventsDBManager()
    
    var selectedEventId: String?
    var editedEvent = Event(title: "", id: "")
    var newEditedEvent = Event(title: "", id: "")
    
    var reminderScheduled = false
    
    var oldReminderDate: Date?
    var newReminderDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        // MARK: View Configuration
        configureTable()
        configureButtons()
        
        //MARK: Date Pickers Configuration
        configureDatePickers()
        
        // MARK: Register Table Cells
        table.register(ReminderTableViewCell.nib(), forCellReuseIdentifier: ReminderTableViewCell.identifier)
        table.register(DeleteEventTableViewCell.nib(), forCellReuseIdentifier: DeleteEventTableViewCell.identifier)
        
        //MARK: Authorization Request (Push Notifications)
        if let id = selectedEventId {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
               for notification: UNNotificationRequest in notifications {
                   if notification.identifier == id {
                       let trigger: UNCalendarNotificationTrigger = notification.trigger as! UNCalendarNotificationTrigger
                       self.oldReminderDate = trigger.nextTriggerDate()
                   }
               }
            }
        }
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        let titleCell = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditEventTableViewCell
        let titleTextField = titleCell.textField
        
        guard let name = titleTextField!.text, !name.isEmpty
        else {
          self.saveButton.isEnabled = false
          return
        }
        saveButton.isEnabled = true
    }
    
    @objc func saveButtonAction() {
        if let id = selectedEventId {

            let titleCell = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditEventTableViewCell
            var title = titleCell.textField.text
            
            var titleIsBlank = true
            for char in title! {
              if !char.isWhitespace {
                  titleIsBlank = false
              }
            }
            if titleIsBlank {
                title = Constants.eventNameDefault.localize()
            }
            
            let locationCell = table.cellForRow(at: IndexPath(row: 1, section: 0)) as! EditEventTableViewCell
            let location = locationCell.textField.text
            let startDate = formatDate(date: datePickerStartDate.date)
            let startTime = formatHour(date: datePickerStartTime.date)
            let endDate = formatDate(date: datePickerEndDate.date)
            let endTime = formatHour(date: datePickerEndTime.date)
            
            
            databaseManager.editEvent(idEvent: id, title: title!, location: location ?? "", startDate: startDate, startTime: startTime, endDate: endDate, endTime: endTime)
            
            if reminderScheduled {
                var idNotification : [String] = []
                idNotification.append(id)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idNotification)
                
                let reminderDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: datePickerReminderDate.date)
                let reminderTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: datePickerReminderTime.date)
                
                var reminderComponents = DateComponents()
                reminderComponents.year = reminderDateComponents.year
                reminderComponents.month = reminderDateComponents.month
                reminderComponents.day = reminderDateComponents.day
                reminderComponents.timeZone = TimeZone.current
                reminderComponents.hour = reminderTimeComponents.hour
                reminderComponents.minute = reminderTimeComponents.minute
                reminderComponents.second = 0

                let calendar = Calendar(identifier: .gregorian)
                let triggerDate = calendar.date(from: reminderComponents) ?? Date().addingTimeInterval(20)
                
                newReminderDate = triggerDate

                let content = UNMutableNotificationContent()
                content.title = Constants.eventNotificationTitle.localize()
                content.sound = .default
                content.body = title ?? ""

                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
                
                let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("error")
                    }
                })
            }

            newEditedEvent = Event(title: title!, id: id, location: location ?? "", startDate: startDate, startTime: startTime, endDate: endDate, endTime: endTime)
            
            NotificationCenter.default.post(name: Notification.Name(Constants.editEventNotification), object: self)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didDeleteEvent() {
        if selectedEventId != nil {
            NotificationCenter.default.post(name: Notification.Name(Constants.deleteEventNotification), object: self)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func cancelButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dateChanged1(datePickerStartDate: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as! EditEventTableViewCell
        cell.setDate(text: formatDate(date: datePickerStartDate.date))
    }
    
    @objc func dateChanged2(datePickerEndDate: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 2, section: 1)) as! EditEventTableViewCell
        cell.setDate(text: formatDate(date: datePickerEndDate.date))
    }
    
    @objc func dateChangedReminder(datePickerReminderDate: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 1, section: 2)) as! EditEventTableViewCell
        cell.setDate(text: formatDate(date: datePickerReminderDate.date))
    }
    
    @objc func hourChanged1(datePickerStartTime: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 1, section: 1)) as! EditEventTableViewCell
        cell.setDate(text: formatHour(date: datePickerStartTime.date))
    }
    
    @objc func hourChanged2(datePickerEndTime: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 3, section: 1)) as! EditEventTableViewCell
        cell.setDate(text: formatHour(date: datePickerEndTime.date))
    }
    
    @objc func hourChangedReminder(datePickerReminderTime: UIDatePicker){
        let cell = table.cellForRow(at: IndexPath(row: 2, section: 2)) as! EditEventTableViewCell
        cell.setDate(text: formatHour(date: datePickerReminderTime.date))
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat.localize()
        return formatter.string(from: date)
    }
    
    func formatHour(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.timeFormat.localize()
        return formatter.string(from: date)
    }
    
    @objc func hideKeyboard() {
      view.endEditing(true)
    }
    
    func configureDatePickers() {
        if #available(iOS 15.0, *) {
            datePickerStartDate.preferredDatePickerStyle = .inline
            datePickerEndDate.preferredDatePickerStyle = .inline
            datePickerReminderDate.preferredDatePickerStyle = .inline
        } else {
            datePickerStartDate.preferredDatePickerStyle = .wheels
            datePickerEndDate.preferredDatePickerStyle = .wheels
            datePickerReminderDate.preferredDatePickerStyle = .wheels
        }
        
        configureDate(datePickerStartDate)
        datePickerStartDate.addTarget(self, action: #selector(dateChanged1(datePickerStartDate:)), for: UIControl.Event.valueChanged)

        configureTime(datePickerStartTime)
        datePickerStartTime.addTarget(self, action: #selector(hourChanged1(datePickerStartTime: )), for: UIControl.Event.valueChanged)
        
        configureDate(datePickerEndDate)
        datePickerEndDate.addTarget(self, action: #selector(dateChanged2(datePickerEndDate:)), for: UIControl.Event.valueChanged)

        configureTime(datePickerEndTime)
        datePickerEndTime.addTarget(self, action: #selector(hourChanged2(datePickerEndTime: )), for: UIControl.Event.valueChanged)
        
        configureDate(datePickerReminderDate)
        datePickerReminderDate.addTarget(self, action: #selector(dateChangedReminder(datePickerReminderDate:)), for: UIControl.Event.valueChanged)

        configureTime(datePickerReminderTime)
        datePickerReminderTime.addTarget(self, action: #selector(hourChangedReminder(datePickerReminderTime: )), for: UIControl.Event.valueChanged)
    }
    
    func configureDate(_ picker: UIDatePicker) {
        picker.datePickerMode = .date
        picker.frame.size = CGSize(width: 0, height: UIScreen.main.bounds.height / 2)
    }
    
    func configureTime(_ picker: UIDatePicker) {
        picker.datePickerMode = .time
        picker.frame.size = CGSize(width: 0, height: 400)
        picker.preferredDatePickerStyle = .wheels
    }
    
    func configureTable() {
        self.table.backgroundColor = Constants.cultured
        self.table.separatorColor = self.table.backgroundColor
    }
    
    func configureButtons() {
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: Constants.cancelButton.localize(), style: .plain, target: self, action: #selector(cancelButtonAction))
        cancelButton.tintColor = .white
        saveButton = UIBarButtonItem(title: Constants.saveButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        saveButton.tintColor = .white
        
        let navigItem: UINavigationItem = UINavigationItem(title: Constants.editEventViewControllerTitle.localize())
        navigItem.rightBarButtonItem = saveButton
        navigItem.leftBarButtonItem = cancelButton
        navigationBar.barTintColor = Constants.primaryBlue
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationBar.items = [navigItem]
    }
}

extension EditEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 2
            case 1:
                return 4
            case 2:
                return 3
            case 3:
                return 1
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        header.backgroundColor = Constants.cultured
        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        footer.backgroundColor = .white
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.editEventCellId, for: indexPath) as! EditEventTableViewCell
            if indexPath.row == 0 {
                cell.configureWithoutPicker(text: self.editedEvent.title, placeholder: Constants.placeholderTitle.localize())
                cell.textField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
                return cell
            } else {
                cell.configureWithoutPicker(text: self.editedEvent.location ?? "", placeholder: Constants.placeholderLocation.localize())
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let reminderCell = tableView.dequeueReusableCell(withIdentifier: ReminderTableViewCell.identifier, for: indexPath) as! ReminderTableViewCell
                reminderCell.delegate = self
                if oldReminderDate != nil {
                    reminderCell.activateSwitch()
                }
                return reminderCell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.editEventCellId, for: indexPath) as! EditEventTableViewCell
                if let oldReminderDate = oldReminderDate {
                    let reminderDate = formatDate(date: oldReminderDate)
                    cell.configure(text: reminderDate, placeholder: Constants.placeholderDateReminder.localize(), picker: datePickerReminderDate)
                }else{
                    cell.configure(text: "", placeholder: Constants.placeholderDateReminder.localize(), picker: datePickerReminderDate)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Constants.editEventCellId, for: indexPath) as! EditEventTableViewCell
                if let oldReminderDate = oldReminderDate {
                    let reminderTime = formatHour(date: oldReminderDate)
                    cell.configure(text: reminderTime, placeholder: Constants.placeholderTimeReminder.localize(), picker: datePickerReminderTime)
                }else{
                    cell.configure(text: "", placeholder: Constants.placeholderTimeReminder.localize(), picker: datePickerReminderTime)
                }
                return cell
            }
        }else if indexPath.section == 3 {
            let deleteEventCell = tableView.dequeueReusableCell(withIdentifier: DeleteEventTableViewCell.identifier, for: indexPath) as! DeleteEventTableViewCell
            deleteEventCell.delegate = self
            return deleteEventCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.editEventCellId, for: indexPath) as! EditEventTableViewCell
            if indexPath.row == 0 {
                cell.configure(text: self.editedEvent.startDate ?? "", placeholder: Constants.placeholderStartDate.localize(), picker: datePickerStartDate)
                return cell
            } else if indexPath.row == 1 {
                cell.configure(text: self.editedEvent.startTime ?? "", placeholder: Constants.placeholderStartTime.localize(), picker: datePickerStartTime)
                return cell
            } else if indexPath.row == 2 {
                cell.configure(text: self.editedEvent.endDate ?? "", placeholder: Constants.placeholderEndDate.localize(), picker: datePickerEndDate)
                return cell
            } else {
                cell.configure(text: self.editedEvent.endTime ?? "", placeholder: Constants.placeholderEndTime.localize(), picker: datePickerEndTime)
                return cell
            }
        }
    }
}

extension EditEventViewController: ReminderCellDelegate {
    
    func didTapSwitchButton(switchButton: UISwitch) {
        let reminderDateCell = table.cellForRow(at: IndexPath(row: 1, section: 2)) as! EditEventTableViewCell
        let reminderTimeCell = table.cellForRow(at: IndexPath(row: 2, section: 2)) as! EditEventTableViewCell
        if switchButton.isOn {
            reminderDateCell.textField.isEnabled = true
            reminderTimeCell.textField.isEnabled = true
            reminderScheduled = true
            var reminderDate = ""
            var reminderTime = ""
            if let oldReminderDate = oldReminderDate {
                reminderDate = formatDate(date: oldReminderDate)
                reminderTime = formatHour(date: oldReminderDate)
            }
            reminderDateCell.configure(text: reminderDate, placeholder: Constants.placeholderDateReminder.localize(), picker: datePickerReminderDate)
            reminderTimeCell.configure(text: reminderTime, placeholder: Constants.placeholderTimeReminder.localize(), picker: datePickerReminderTime)
        } else {
            reminderDateCell.textField.isEnabled = false
            reminderTimeCell.textField.isEnabled = false
            reminderScheduled = false
            reminderDateCell.configureWithoutPicker(text: "", placeholder: "")
            reminderTimeCell.configureWithoutPicker(text: "", placeholder: "")
        }
    }
}

extension EditEventViewController: DeleteEventCellDelegate {
    
    func didTapDeleteButton() {
        if let id = selectedEventId {
            //MARK: Delete Notification from OS
            var idNotification : [String] = []
            idNotification.append(id)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idNotification)

            //MARK: Delete Event from DB
            databaseManager.deleteEvent(id)
        }
        didDeleteEvent()
    }
    
}
