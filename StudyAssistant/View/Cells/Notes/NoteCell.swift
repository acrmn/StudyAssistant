//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol NoteCellDelegate {
    func didTapKeywordsButton(idNote: String, lessonTitle: String)
    func didTapConnectionsButton(idNote: String, lessonTitle: String)
    func didTapEditNoteButton(idNote: String)
    func didTapShareNoteButton(note: Note)
    func didTapDeleteNoteButton(idNote: String)
}

class NoteCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardlabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var keywordsButton: UIButton!
    @IBOutlet weak var connectionsButton: UIButton!
    @IBOutlet weak var typeImage: UIImageView!
    
    var delegate: NoteCellDelegate?
    var lessonTitle: String?
    var idNote: String?
    var note: Note?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: Constants.editNoteOption.localize(), image: UIImage(systemName: "pencil")) { action in
                self.delegate?.didTapEditNoteButton(idNote: self.idNote!)
            },
            UIAction(title: Constants.shareNoteOption.localize(), image: UIImage(systemName: "square.and.arrow.up")) { action in
                self.delegate?.didTapShareNoteButton(note: self.note!)
            },
            UIAction(title: Constants.deleteNoteOption.localize(), image: UIImage(systemName: "trash")) { action in
                self.delegate?.didTapDeleteNoteButton(idNote: self.idNote!)
            }
        ])
        optionsButton.showsMenuAsPrimaryAction = true
        optionsButton.menu = menu
        optionsButton.tintColor = Constants.salmon
        keywordsButton.setTitle(Constants.keywordsButton.localize(), for: .normal)
        connectionsButton.setTitle(Constants.connectionsButton.localize(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    func configure(cardTitle: String, idNote: String, type: String){
        cardlabel.text = cardTitle
        cardlabel.textColor = Constants.gunmetal
        cardlabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        cardlabel.adjustsFontSizeToFitWidth = false
        cardlabel.lineBreakMode = .byTruncatingTail
        
        self.lessonTitle = cardTitle
        self.idNote = idNote
        if type == Constants.imageType {
            typeImage.image = UIImage(named: "image_icon")
        } else {
            typeImage.image = UIImage(named: "file_icon")
        }
        
        cardView.layer.cornerRadius = 15.0
        cardView.layer.shadowColor = Constants.gunmetal?.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        cardView.layer.shadowOpacity = 0.2
        keywordsButton.layer.cornerRadius = 15.0
        connectionsButton.layer.cornerRadius = 15.0
        keywordsButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        connectionsButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        keywordsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        connectionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
    }
    
    @IBAction func keywordsButtonAction(_ sender: Any) {
        delegate?.didTapKeywordsButton(idNote: idNote!, lessonTitle: lessonTitle!)
    }
    
    @IBAction func connectionsButtonAction(_ sender: Any) {
        delegate?.didTapConnectionsButton(idNote: idNote!, lessonTitle: lessonTitle!)
    }
}
