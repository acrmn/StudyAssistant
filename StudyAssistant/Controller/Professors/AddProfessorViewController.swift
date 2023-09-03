//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol ProfessorsTableDelegate {
    func didAddProfessor(professorName: String, professorId: String, professorOffice: String, professorImage: String)
}

class AddProfessorViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
        
    var cancelButton = UIBarButtonItem()
    var saveButton = UIBarButtonItem()
    
    var professorDelegate: ProfessorsTableDelegate!
    let databaseManager = ProfessorsDBManager()
    
    var imageName: String?
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        saveButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        // MARK: View Configuration
        configureTable()
        configureButtons()
        
        // MARK: Register Table Cells
        table.register(ImageProfessorTableViewCell.nib(), forCellReuseIdentifier: ImageProfessorTableViewCell.identifier)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        let nameCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as! AddProfessorTableViewCell
        let nameTextField = nameCell.textField
        guard let name = nameTextField!.text, !name.isEmpty
        else {
          self.saveButton.isEnabled = false
          return
        }
        saveButton.isEnabled = true
    }
    
    @objc func saveButtonAction() {
        
        let nameCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as! AddProfessorTableViewCell
        var name = nameCell.textField.text
        var nameIsBlank = true
        for char in name! {
          if !char.isWhitespace {
              nameIsBlank = false
          }
        }
        let officeCell = table.cellForRow(at: IndexPath(row: 1, section: 1)) as! AddProfessorTableViewCell
        let office = officeCell.textField.text
        let emailCell = table.cellForRow(at: IndexPath(row: 2, section: 1)) as! AddProfessorTableViewCell
        let email = emailCell.textField.text

        if nameIsBlank {
            name = Constants.professorNameDefault
        }
        
        if let imageName = imageName, let office = office, let email = email {
            let idProfessor = databaseManager.addProfessor(name: name!, office: office, email: email, imageName: imageName)
            
            professorDelegate.didAddProfessor(professorName: name!, professorId: idProfessor, professorOffice: office, professorImage: imageName)
        }

        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func cancelButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
      view.endEditing(true)
    }
    
    @objc func tapEdit(recognizer: UITapGestureRecognizer) {
        let profileSelectorVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.profileSelectorViewControllerId)) as! ProfileSelectorViewController
        profileSelectorVC.imageDelegate = self
        self.present(profileSelectorVC, animated: true)
    }
    
    func configureTable() {
        self.table.backgroundColor = Constants.cultured
        self.table.separatorColor = self.table.backgroundColor
    }
    
    func configureButtons() {
        saveButton = UIBarButtonItem(title: Constants.saveButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        saveButton.tintColor = .white
        cancelButton = UIBarButtonItem(title: Constants.cancelButton.localize(), style: .plain, target: self, action: #selector(cancelButtonAction))
        cancelButton.tintColor = .white
        
        let navigItem: UINavigationItem = UINavigationItem(title: Constants.addProfessorViewControllerTitle.localize())
        navigItem.rightBarButtonItem = saveButton
        navigItem.leftBarButtonItem = cancelButton
        navigationBar.items = [navigItem]
        navigationBar.barTintColor = Constants.primaryBlue
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
}

extension AddProfessorViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 1
            case 1:
                return 3
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        header.backgroundColor = Constants.cultured
        return header
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        footer.backgroundColor = .white
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 125
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let imageProfessorCell = tableView.dequeueReusableCell(withIdentifier: ImageProfessorTableViewCell.identifier, for: indexPath) as! ImageProfessorTableViewCell
            imageProfessorCell.configure(imageName: Constants.profileImageDefault)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
            imageProfessorCell.profileImage.addGestureRecognizer(recognizer)
            return imageProfessorCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.addProfessorCellId, for: indexPath) as! AddProfessorTableViewCell
            if indexPath.row == 0 {
                cell.configure(text: "", placeholder: Constants.placeholderName.localize())
                cell.textField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
                return cell
            } else if indexPath.row == 1 {
                cell.configure(text: "", placeholder: Constants.placeholderOffice.localize())
                return cell
            } else {
                cell.configure(text: "", placeholder: Constants.placeholderEmail.localize())
                return cell
            }
        }

    }

}

//MARK: - Delegates
extension AddProfessorViewController: ProfessorsImageDelegate {
    
    func didChangeProfessorImage(imageName: String) {
        let imageCell = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! ImageProfessorTableViewCell
        imageCell.configure(imageName: imageName)
        self.imageName = imageName
    }
    
}
