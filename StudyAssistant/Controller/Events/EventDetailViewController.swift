//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var databaseManager = EventsDBManager()
    
    var event = Event(title: "", id: "")
    var selectedEventId: String?
    var oldReminderDate: Date?
    var selectedEventName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedEventName
        
        databaseManager.eventDetailDelegate = self
        
        // MARK: Initial Data Load
        if let idEvent = selectedEventId {
            databaseManager.loadSingleEvent(idEvent)
        }
        
        // MARK: View Configuration
        configureTable()
        configureButtons()

        // MARK: Register Table Cells
        table.register(EventInfoTableViewCell.self, forCellReuseIdentifier: EventInfoTableViewCell.identifier)
        
        // MARK: Observers (Edit & Delete Event)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditEvent), name: Notification.Name(Constants.editEventNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteEvent), name: Notification.Name(Constants.deleteEventNotification), object: nil)
        
        //MARK: Reminder
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
    
    @objc func editButtonAction() {
        let editEventVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.editEventViewControllerId)) as! EditEventViewController
        editEventVC.selectedEventId = selectedEventId
        editEventVC.editedEvent = self.event
        if(oldReminderDate != nil){
            editEventVC.reminderScheduled = true
        }
        self.present(editEventVC, animated: true)
    }
    
    @objc func didDeleteEvent(notification: Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didEditEvent(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditEventViewController
        self.event = editVC.newEditedEvent
        self.oldReminderDate = editVC.newReminderDate
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
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
    
    func configureTable() {
        self.table.backgroundColor = Constants.cultured
        self.table.separatorColor = self.table.backgroundColor
    }
    
    func configureButtons() {
        let editButton: UIBarButtonItem = UIBarButtonItem(title: Constants.editButton.localize(), style: .plain, target: self, action: #selector(editButtonAction))
        editButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = editButton
    }
}

// MARK: - Table Delegates
extension EventDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 1
            case 1:
                return 4
            case 2:
                return 1
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 125
        }
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
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.eventInfoTableViewCellId, for: indexPath) as! EventInfoTableViewCell
            cell.set(name: self.event.title, ubi: self.event.location ?? "")
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.eventFieldCellId, for: indexPath) as! EventDateTableViewCell
            var reminderDate = ""
            var reminderTime = ""
            if oldReminderDate != nil {
                reminderDate = formatDate(date: oldReminderDate ?? Date())
                reminderTime = formatHour(date: oldReminderDate ?? Date())
            }
            cell.configure(staticText: Constants.placeholderReminder.localize(), dataText: reminderDate + " " + reminderTime)
                return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.eventFieldCellId, for: indexPath) as! EventDateTableViewCell
            if indexPath.row == 0 {
                cell.configure(staticText: Constants.placeholderStartDate.localize(), dataText: self.event.startDate ?? "")
                return cell
            } else if indexPath.row == 1 {
                cell.configure(staticText: Constants.placeholderStartTime.localize(), dataText: self.event.startTime ?? "")
                return cell
            } else if indexPath.row == 2 {
                cell.configure(staticText: Constants.placeholderEndDate.localize(), dataText: self.event.endDate ?? "")
                return cell
            } else {
                cell.configure(staticText: Constants.placeholderEndTime.localize(), dataText: self.event.endTime ?? "")
                return cell
            }
        }
    }
}

// MARK: - Delegates
extension EventDetailViewController: EventsDBManagerDetail {
    
    func didLoadSingleEvent(databaseManager: EventsDBManager, data: Event) {
        event = data
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}
