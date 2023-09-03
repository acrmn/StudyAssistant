//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class SimpleKeywordTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    func configure(keywordName: String){
        label.text = keywordName
        label.textColor = Constants.gunmetal
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
    }

}
