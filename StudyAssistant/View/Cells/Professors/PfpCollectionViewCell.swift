//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class PfpCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                layer.borderWidth = 3.5
                layer.borderColor = Constants.salmon?.cgColor
            } else {
                layer.borderWidth = 0
            }
        }
    }
}
