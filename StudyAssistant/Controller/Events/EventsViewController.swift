//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EventsViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!

    var events = [Event]()
    var databaseManager = EventsDBManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = Constants.eventsViewControllerTitle.localize()
        self.tabBarController?.tabBar.items?[0].title = Constants.eventsViewControllerTitle.localize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseManager.eventLoadDelegate = self
        
        // MARK: View Configuration
        configureNavBar()
        
        // MARK: Register Table Cells
        table.register(EventTableViewCell.self, forCellReuseIdentifier: EventTableViewCell.identifier)
        
        // MARK: Initial Data Load
        databaseManager.loadEvents()
        
        // MARK: Observers (Edit & Delete Event)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditEvent), name: Notification.Name(Constants.editEventNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteEvent), name: Notification.Name(Constants.deleteEventNotification), object: nil)
    }
    
    @objc func addButtonAction() {
        let addEventVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.addEventViewControllerId)) as! AddEventViewController
        addEventVC.eventDelegate = self
        self.present(addEventVC, animated: true)
    }
    
    @objc func didEditEvent(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditEventViewController
        let editedEvent = editVC.newEditedEvent
        if let idx = events.firstIndex(where: {$0.id == editedEvent.id}){
            events[idx].title = editedEvent.title
            events[idx].startDate = editedEvent.startDate
        }
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    @objc func didDeleteEvent(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditEventViewController
        let deletedEventId = editVC.selectedEventId
        if let idx = events.firstIndex(where: {$0.id == deletedEventId}){
            events.remove(at: idx)
        }
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.barTintColor = Constants.primaryBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }
    
}

extension EventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.eventCellId, for: indexPath) as! EventTableViewCell
        cell.configure(eventName: events[indexPath.row].title, startDate: events[indexPath.row].startDate ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let eventDetailVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.eventDetailViewControllerId)) as! EventDetailViewController
        eventDetailVC.selectedEventId = events[indexPath.row].id
        eventDetailVC.selectedEventName = events[indexPath.row].title
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //MARK: Delete Event (Swipe Gesture)
        let deleteAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in

            var idNotification : [String] = []
            let idEvent = self.events[indexPath.row].id
            
            idNotification.append(idEvent)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idNotification)
            
            self.databaseManager.deleteEvent(idEvent)
            
            if let idx = self.events.firstIndex(where: {$0.id == idEvent}){
                self.events.remove(at: idx)
            }

            DispatchQueue.main.async {
                self.table.reloadData()
            }

            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - Delegates
extension EventsViewController: EventsTableDelegate {
    
    func didAddEvent(eventTitle: String, eventId: String, eventStartDate: String) {
        let addedEvent = Event(title: eventTitle, id: eventId)
        addedEvent.startDate = eventStartDate
        self.events.insert(addedEvent, at: 0)
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}

extension EventsViewController: EventsDBManagerLoad {
    
    func didLoadEvents(databaseManager: EventsDBManager, data: [Event]) {
        events = data
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}
