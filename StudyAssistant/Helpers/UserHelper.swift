//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

class UserHelper{
    
    static func getUserEmail() -> String {
        let defaults = UserDefaults.standard
        let userEmail = defaults.string(forKey: "userEmail") ?? "noEmail"
        return userEmail
    }
    
}
