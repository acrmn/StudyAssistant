//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

class Event {
    
    // MARK: - Propiedades
    var title: String
    var id: String
    var location: String?
    var startDate: String?
    var startTime: String?
    var endDate: String?
    var endTime: String?

    // MARK: - Constructor
    init (title: String, id: String) {
        self.title = title
        self.id = id
    }
    
    init(title: String, id: String, location: String, startDate: String, startTime: String, endDate: String, endTime: String) {
        self.title = title
        self.id = id
        self.location = location
        self.startDate = startDate
        self.startTime = startTime
        self.endDate = endDate
        self.endTime = endTime
    }
}
