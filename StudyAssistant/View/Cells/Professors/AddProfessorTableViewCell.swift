//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class AddProfessorTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    func configure(text: String, placeholder: String){
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = Constants.gunmetal
    }

}
