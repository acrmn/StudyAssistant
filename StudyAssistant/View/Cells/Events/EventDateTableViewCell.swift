//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EventDateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var staticLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
 
    func configure(staticText: String, dataText: String){
        staticLabel.text = staticText
        staticLabel.textColor = Constants.gunmetal
        dataLabel.text = dataText
        dataLabel.textColor = .gray
    }
}
