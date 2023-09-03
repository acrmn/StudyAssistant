//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class ImageProfessorTableViewCell: UITableViewCell {
    
    static let identifier = Constants.imageProfessorTableViewCellId
    @IBOutlet weak var profileImage: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: Constants.imageProfessorTableViewCellId, bundle: nil)
    }
    
    func configure(imageName: String){
        self.profileImage.isUserInteractionEnabled = true;
        
        self.selectionStyle = .none
        profileImage.layer.borderWidth = 0.8
        profileImage.layer.borderColor = Constants.cultured?.cgColor
        self.profileImage.layoutIfNeeded()
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.image = UIImage(named: imageName)
    }
    
}
