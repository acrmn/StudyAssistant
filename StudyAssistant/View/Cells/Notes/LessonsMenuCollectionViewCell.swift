//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class LessonsMenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    
    override var isSelected: Bool {
        didSet {
            view.layer.backgroundColor = self.isSelected ? Constants.salmon?.cgColor : Constants.cultured2?.cgColor
            label.textColor = self.isSelected ? .white : Constants.gunmetal
        }
    }
    
    func configure(with lesson: String){
        label.text = lesson
        label.textColor = Constants.gunmetal

        view.layer.cornerRadius = 20.0
        view.layer.backgroundColor = Constants.cultured2?.cgColor
    }
}
