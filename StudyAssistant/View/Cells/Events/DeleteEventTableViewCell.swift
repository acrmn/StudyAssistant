//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol DeleteEventCellDelegate {
    func didTapDeleteButton()
}

class DeleteEventTableViewCell: UITableViewCell {

    static let identifier = Constants.deleteEventTableViewCellId
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: DeleteEventCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: Constants.deleteEventTableViewCellId, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.setTitle(Constants.deleteEventButton.localize(), for: .normal)
        deleteButton.backgroundColor = .white
        deleteButton.tintColor = .red
        deleteButton.addTarget(self,action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton(sender: UIButton) {
        self.delegate?.didTapDeleteButton()
    }
    
}
