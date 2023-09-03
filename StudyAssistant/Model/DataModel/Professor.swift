//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

class Professor {
    
    // MARK: - Properties
    var name: String
    var id: String
    var office: String?
    var email: String?
    var profilePic: String?

    // MARK: - Constructor
    init ( name: String, id: String) {
        self.name = name
        self.id = id
    }
    
    init(name: String, id: String, office: String, email: String, profilePic: String) {
        self.name = name
        self.id = id
        self.office = office
        self.email = email
        self.profilePic = profilePic
    }
    
}
