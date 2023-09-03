//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol HeaderCellDelegate {
    func tappedAddLessonOption(subject: Subject)
    func tappedEditSubjectOption(asignatura: Subject)
    func tappedDeleteSubjectOption(asignatura: Subject)
}

class HeaderTableViewCell: UITableViewCell {

    static let identifier = Constants.headerTableViewCellId
    var delegate: HeaderCellDelegate?
    var asignatura: Subject?
    var subjectID: String?
    
    let cellView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        return view
    }()

    let labelName: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.gunmetal
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        return label
    }()
    
    let optionsButton: UIButton = {
        var button = UIButton()
        let configuration = UIImage.SymbolConfiguration(weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        let customSymbolImage = UIImage(systemName: "ellipsis.circle", withConfiguration: configuration)
        button.setImage(customSymbolImage, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.tintColor = .white
        return button
    }()
    
    func set(asignatura: Subject) {
        self.asignatura = asignatura
        subjectID = asignatura.id
        labelName.text = asignatura.title
        cellView.backgroundColor = UIColor(red: asignatura.color?[Constants.redComp] ?? 0.0,
                                           green: asignatura.color?[Constants.greenComp] ?? 0.0,
                                           blue: asignatura.color?[Constants.blueComp] ?? 0.0, alpha: 1)
        cellView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(cellView)
        
        // MARK: - Opciones de la asignatura
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: Constants.addLessonOption.localize(), image: UIImage(systemName: "plus")) { action in
                if let asignatura = self.asignatura {
                    self.delegate?.tappedAddLessonOption(subject: asignatura)
                }
            },
            UIAction(title: Constants.editSubjectOption.localize(), image: UIImage(systemName: "pencil")) { action in
                if let asignatura = self.asignatura {
                    self.delegate?.tappedEditSubjectOption(asignatura: asignatura)
                }
            },
            UIAction(title: Constants.deleteSubjectOption.localize(), image: UIImage(systemName: "trash")) { action in
                if let asignatura = self.asignatura {
                    self.delegate?.tappedDeleteSubjectOption(asignatura: asignatura)
                }
                
            }
        ])
        optionsButton.menu = menu
        
        cellView.addSubview(optionsButton)
        cellView.addSubview(labelName)
        
        NSLayoutConstraint.activate([
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            optionsButton.trailingAnchor.constraint(equalTo: labelName.trailingAnchor),
            optionsButton.bottomAnchor.constraint(equalTo: labelName.topAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            labelName.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 25),
            labelName.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
            labelName.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
