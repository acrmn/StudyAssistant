//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

extension String {
    
    func localize() -> String {
        return NSLocalizedString(self,
                                 tableName: "Localization",
                                 bundle: .main,
                                 value: self,
                                 comment: self)
    }
    
}
