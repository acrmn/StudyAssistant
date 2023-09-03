//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

class Subject {
    
    // MARK: - Propiedades
    var title: String
    var id: String
    var color: [String:CGFloat]?
    var expanded: Bool?
    var lessons: [String]? = []
    var lessonsDictionary: [String:String]? = [:]
    
    // MARK: - Constructor
    init (title: String, id: String) {
        self.title = title
        self.id = id
    }
}
