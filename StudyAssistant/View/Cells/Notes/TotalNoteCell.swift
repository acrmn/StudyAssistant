//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseStorage

protocol TotalNoteCellDelegate {
    func didTapConnectButton(pathNote: String)
}

class TotalNoteCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var preview: UIImageView!
    
    var delegate: TotalNoteCellDelegate?
    var pathNote: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(cardTitle: String, pathNote: String?, storage: Storage, url: String){
        cardLabel.text = cardTitle
        cardLabel.textColor = Constants.gunmetal
        cardLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        cardLabel.adjustsFontSizeToFitWidth = false
        cardLabel.lineBreakMode = .byTruncatingTail
        self.pathNote = pathNote
        
        preview.loadImage(storage: storage, url: url)        
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.layer.cornerRadius = 15
        preview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        cardView.layer.backgroundColor = Constants.cultured2?.cgColor
        cardView.layer.shadowColor = Constants.gunmetal?.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.cornerRadius = 15.0
        cardView.layer.cornerRadius = 15.0

        connectButton.layer.cornerRadius = 15.0
        connectButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        connectButton.setTitle(Constants.connectButton.localize(), for: .normal)
    }
    
    func configurePdfCell(cardTitle: String, pathNote: String?, cardImage: UIImage, storage: Storage, url: String){
        cardLabel.text = cardTitle
        cardLabel.textColor = Constants.gunmetal
        cardLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        cardLabel.adjustsFontSizeToFitWidth = false
        cardLabel.lineBreakMode = .byTruncatingTail
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        self.pathNote = pathNote
       
        preview.image = cardImage
        preview.contentMode = .scaleAspectFill
        preview.clipsToBounds = true
        preview.layer.cornerRadius = 15
        preview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        cardView.layer.backgroundColor = Constants.cultured2?.cgColor
        cardView.layer.shadowColor = Constants.gunmetal?.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.cornerRadius = 15.0
        cardView.layer.cornerRadius = 15.0
        
        connectButton.layer.cornerRadius = 15.0
        connectButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        connectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        connectButton.setTitle(Constants.connectButton.localize(), for: .normal)
    }

    @IBAction func connectButtonAction(_ sender: Any) {
        delegate?.didTapConnectButton(pathNote: pathNote!)
    }

}
