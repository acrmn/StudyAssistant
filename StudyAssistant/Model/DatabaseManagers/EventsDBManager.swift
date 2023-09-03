//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

protocol EventsDBManagerLoad {
    func didLoadEvents(databaseManager: EventsDBManager, data: [Event])
}

protocol EventsDBManagerDetail {
    func didLoadSingleEvent(databaseManager: EventsDBManager, data: Event)
}

struct EventsDBManager {
    
    private let db = Constants.firestoreRef
    let storage = Constants.storageRef
    
    var eventLoadDelegate : EventsDBManagerLoad?
    var eventDetailDelegate: EventsDBManagerDetail?
    
    func loadEvents() {
        var events = [Event]()
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionEvents).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting events documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let event = Event(title: document.get(Constants.fieldEventTitle) as! String,
                                       id: document.documentID)
                    event.startDate = document.get(Constants.fieldEventStartDate) as? String
                    events.append(event)
                }
                eventLoadDelegate?.didLoadEvents(databaseManager: self, data: events)
            }
        }
    }
    
    func loadSingleEvent(_ idEvent: String) {
        var event = Event(title: "", id: "")
        
        let docRef = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionEvents).document(idEvent)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                event = Event(title: document.get(Constants.fieldEventTitle) as! String,
                                   id: document.documentID)
                event.location = document.get(Constants.fieldEventLocation) as? String
                event.startDate = document.get(Constants.fieldEventStartDate) as? String
                event.startTime = document.get(Constants.fieldEventStartTime) as? String
                event.endDate = document.get(Constants.fieldEventEndDate) as? String
                event.endTime = document.get(Constants.fieldEventEndTime) as? String
                eventDetailDelegate?.didLoadSingleEvent(databaseManager: self, data: event)
            } else {
                print("Error getting events document")
            }
        }
    }
    
    func addEvent(title: String, location :String, startDate :String, startTime :String, endDate :String, endTime :String) -> String {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionEvents).document()
        ref.setData([Constants.fieldEventTitle: title,
                     Constants.fieldEventLocation: location,
                     Constants.fieldEventStartDate: startDate,
                     Constants.fieldEventStartTime: startTime,
                     Constants.fieldEventEndDate: endDate,
                     Constants.fieldEventEndTime: endTime])
        return ref.documentID
    }
    
    func editEvent(idEvent: String, title: String, location :String, startDate :String, startTime :String, endDate :String, endTime :String) {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionEvents).document(idEvent)
        
        ref.updateData([Constants.fieldEventTitle: title,
                        Constants.fieldEventLocation: location as Any,
                     Constants.fieldEventStartDate: startDate,
                     Constants.fieldEventStartTime: startTime,
                     Constants.fieldEventEndDate: endDate,
                     Constants.fieldEventEndTime: endTime])
    }
    
    func deleteEvent(_ idEvent: String) {
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionEvents).document(idEvent).delete(){ err in
            if let err = err {
                print("Error removing document: \(err)")
            }
        }
    }
    
}
