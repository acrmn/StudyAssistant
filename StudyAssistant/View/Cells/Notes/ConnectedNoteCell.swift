//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseStorage

class ConnectedNoteCell: UITableViewCell {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(cardTitle: String, cardImage: UIImage, storage: Storage, url: String){
        titleLabel.text = cardTitle
        titleLabel.textColor = Constants.gunmetal
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail

        previewImage.loadImage(storage: storage, url: url)
        previewImage.contentMode = .scaleAspectFill
        previewImage.clipsToBounds = true
        previewImage.layer.cornerRadius = 15
        previewImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        cardView.layer.backgroundColor = Constants.cultured?.cgColor
        cardView.layer.cornerRadius = 15.0
        cardView.layer.shadowColor = Constants.gunmetal?.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        cardView.layer.shadowOpacity = 0.2
    }
    
    func configurePdfCell(cardTitle: String, cardImage: UIImage, storage: Storage, url: String){
        titleLabel.text = cardTitle
        titleLabel.textColor = Constants.gunmetal
        titleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = false
        titleLabel.lineBreakMode = .byTruncatingTail

        previewImage.image = cardImage
        previewImage.contentMode = .scaleAspectFill
        previewImage.clipsToBounds = true
        previewImage.layer.cornerRadius = 15
        previewImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        cardView.layer.backgroundColor = Constants.cultured?.cgColor
        cardView.layer.cornerRadius = 15.0
        cardView.layer.shadowColor = Constants.gunmetal?.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        cardView.layer.shadowOpacity = 0.2
    }

}
