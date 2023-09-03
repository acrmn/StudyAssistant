//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

extension UIColor {
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        
        var redComponent: CGFloat = 0
        var greenComponent: CGFloat = 0
        var blueComponent: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&redComponent, green: &greenComponent, blue: &blueComponent, alpha: &alpha)

        return (redComponent, greenComponent, blueComponent, alpha)
    }
}
