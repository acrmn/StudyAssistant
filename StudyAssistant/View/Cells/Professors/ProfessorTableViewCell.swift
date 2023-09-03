//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class ProfessorTableViewCell: UITableViewCell {
    
    static let identifier = Constants.professorTableViewCellId

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var officeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    func configure(professorName: String, professorOffice: String, professorImage: String){
        nameLabel.text = professorName
        officeLabel.text = professorOffice
        profileImage.image = UIImage(named: professorImage)
        
        nameLabel.textColor = Constants.gunmetal
        officeLabel.textColor = Constants.gunmetal
        nameLabel.adjustsFontSizeToFitWidth = false
        nameLabel.lineBreakMode = .byTruncatingTail
        officeLabel.adjustsFontSizeToFitWidth = false
        officeLabel.lineBreakMode = .byTruncatingTail
        view.layer.cornerRadius = 15.0
        view.layer.shadowColor = Constants.gunmetal?.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        view.layer.shadowOpacity = 0.2
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
    }
    
    func updateImage(professorImage: String) {
        profileImage.image = UIImage(named: professorImage)
    }
}
