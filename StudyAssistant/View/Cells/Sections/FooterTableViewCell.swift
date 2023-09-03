//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class FooterTableViewCell: UITableViewCell {

    static let identifier = Constants.footerTableViewCellId
    var asignatura: Subject?
    
    let cellView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        view.backgroundColor = UIColor.cyan
        return view
    }()
    
    func set(asignatura: Subject) {
        self.asignatura = asignatura
        cellView.backgroundColor = UIColor(red: asignatura.color?[Constants.redComp] ?? 0.0,
                                           green: asignatura.color?[Constants.greenComp] ?? 0.0,
                                           blue: asignatura.color?[Constants.blueComp] ?? 0.0, alpha: 1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(cellView)
        NSLayoutConstraint.activate([
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
