//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class KeywordTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with keyword: String){
        label.text = keyword
        label.textColor = Constants.gunmetal

        view.layer.cornerRadius = 15.0
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
    }

}
