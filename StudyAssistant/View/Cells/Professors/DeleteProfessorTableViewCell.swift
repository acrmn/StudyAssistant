//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol DeleteProfessorCellDelegate {
    func didTapDeleteButton()
}

class DeleteProfessorTableViewCell: UITableViewCell {

    static let identifier = Constants.deleteProfessorTableViewCellId
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: DeleteProfessorCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: Constants.deleteProfessorTableViewCellId, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.setTitle(Constants.deleteProfessorButton.localize(), for: .normal)
        deleteButton.backgroundColor = .white
        deleteButton.tintColor = .red
        deleteButton.addTarget(self,action: #selector(didTapButton), for: .touchUpInside)
    }
    
    @objc func didTapButton(sender: UIButton) {
        self.delegate?.didTapDeleteButton()
    }
    
}




    

    


