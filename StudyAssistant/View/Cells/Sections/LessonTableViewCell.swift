//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class LessonTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    var asignatura: Subject?
    
    func configure(lesson: String, subject: Subject){
        //Contenido
        label.text = lesson
        self.asignatura = subject
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.textColor = Constants.gunmetal
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)

        // Aspecto
        view.backgroundColor = UIColor(red: asignatura?.color?[Constants.redComp] ?? 0.0,
                                       green: asignatura?.color?[Constants.greenComp] ?? 0.0,
                                       blue: asignatura?.color?[Constants.blueComp] ?? 0.0, alpha: 1)
        view.layer.cornerRadius = 15.0
        view.layer.shadowColor = Constants.gunmetal?.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
        view.layer.shadowOpacity = 0.2
        
        self.selectionStyle = .none
    }
}
