//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    static let identifier = Constants.eventTableViewCellId
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(eventName: String, startDate: String){
        // Contenido
        label.text = eventName
        dateLabel.text = startDate
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        dateLabel.adjustsFontSizeToFitWidth = false
        dateLabel.lineBreakMode = .byTruncatingTail
        
        // Aspecto
        view.layer.cornerRadius = 15.0
        view.layer.shadowColor = Constants.gunmetal?.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        view.layer.shadowOpacity = 0.2
    }
    
}
