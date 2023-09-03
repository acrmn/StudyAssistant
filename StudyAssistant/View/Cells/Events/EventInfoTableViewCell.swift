//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EventInfoTableViewCell: UITableViewCell {
    
    static let identifier = Constants.eventInfoTableViewCellId
    var name: String?
    var ubi: String?
    
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
        label.backgroundColor = .white
        return label
    }()
    
    let labelUbi: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.gunmetal
        label.backgroundColor = .white
        return label
    }()
    
    func set(name: String, ubi: String) {
        self.name = name
        self.ubi = ubi
        labelName.text = name
        labelUbi.text = ubi
        cellView.backgroundColor = .white
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(cellView)
        
        cellView.addSubview(labelName)
        cellView.addSubview(labelUbi)
        
        NSLayoutConstraint.activate([
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            labelName.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 25),
            labelName.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 25),
            labelName.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -25),
            labelName.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate([
            labelUbi.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 25),
            labelUbi.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 75),
            labelUbi.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -25),
            labelUbi.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
