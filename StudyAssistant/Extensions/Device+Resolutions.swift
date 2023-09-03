//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit

extension UIDevice {
    
    enum Device: String {
        case iPhone_SE_1st_Gen = "iPhone SE 1st Gen"
        case iPhone_SE_2nd_Gen = "iPhone SE 2nd Gen, iPhone 8, iPhone 7, iPhone 6S"
        case iPhone_11 = "iPhone 11, iPhone XR"
        case iPhone_8_Plus = "iPhone 8 Plus"
        case iPhone_7_Plus = "iPhone 7 Plus, iPhone 6S Plus"
        case iPhone_13_Mini = "iPhone 13 Mini, iPhone 12 Mini"
        case iPhone_11_Pro = "iPhone 11 Pro, iPhone XS, iPhone X"
        case iPhone_13 = "iPhone 13, iPhone 13 Pro, iPhone 12, iPhone 12 Pro"
        case iPhone_11_Pro_Max = "iPhone 11 Pro Max, iPhone XS Max"
        case iPhone_13_Pro_Max = "iPhone 13 Pro Max, iPhone 12 Pro Max"
        case other = "other"
    }
    
    var deviceType: Device {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            return .iPhone_SE_1st_Gen
        case 1334:
            return .iPhone_SE_2nd_Gen
        case 1792:
            return .iPhone_11
        case 1920:
            return .iPhone_8_Plus
        case 2208:
            return .iPhone_7_Plus
        case 2340:
            return .iPhone_13_Mini
        case 2436:
            return .iPhone_11_Pro
        case 2532:
            return .iPhone_13
        case 2688:
            return .iPhone_11_Pro_Max
        case 2778:
            return .iPhone_13_Pro_Max
        default:
            return .other
        }
    }
}
