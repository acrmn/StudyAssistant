//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol ReminderCellDelegate {
    func didTapSwitchButton(switchButton: UISwitch)
}

class ReminderTableViewCell: UITableViewCell {

    static let identifier = Constants.reminderTableViewCellId
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    var delegate: ReminderCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: Constants.reminderTableViewCellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reminderLabel.textColor = Constants.gunmetal
        reminderLabel.text = Constants.eventScheduleReminder.localize()
        reminderSwitch.setOn(false, animated: false)
        reminderSwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        accessoryView = reminderSwitch
    }
    
    func activateSwitch() {
        reminderSwitch.setOn(true, animated: false) 
    }
    
    @objc func didChangeSwitch(sender: UISwitch) {
        self.delegate?.didTapSwitchButton(switchButton: sender)
    }
}
