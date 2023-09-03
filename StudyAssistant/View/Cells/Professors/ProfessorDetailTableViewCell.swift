//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class ProfessorDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    func configure(data: String, clickable: Bool){
        label.text = data
        label.lineBreakMode = .byTruncatingTail
        if clickable {
            label.textColor = Constants.salmon
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        } else {
            label.textColor = Constants.gunmetal
        }
    }

}
