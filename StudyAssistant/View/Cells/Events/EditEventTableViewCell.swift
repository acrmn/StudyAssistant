//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EditEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    var contentD: String?
    
    func configure(text: String, placeholder: String, picker: UIDatePicker){
        textField.text = text
        textField.placeholder = placeholder
        textField.inputView = picker
        textField.textColor = Constants.gunmetal
    }
    
    func configureWithoutPicker(text: String, placeholder: String){
        textField.text = text
        textField.placeholder = placeholder
    }
    
    func setDate(text: String){
        textField.text = text
    }
}
