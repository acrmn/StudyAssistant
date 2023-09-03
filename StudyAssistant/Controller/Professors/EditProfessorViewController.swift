//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class EditProfessorViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var table: UITableView!
    
    var saveButton = UIBarButtonItem()
    
    var databaseManager = ProfessorsDBManager()
    
    var selectedProfessorId: String?
    var editedProfessor = Professor(name: "", id: "")
    var newEditedProfessor = Professor(name: "", id: "")
    var imageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        // MARK: View Configuration
        configureTable()
        configureButtons()
        
        // MARK: Register Table Cells
        table.register(DeleteProfessorTableViewCell.nib(), forCellReuseIdentifier: DeleteProfessorTableViewCell.identifier)
        table.register(ImageProfessorTableViewCell.nib(), forCellReuseIdentifier: ImageProfessorTableViewCell.identifier)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        let nameCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as! EditProfessorTableViewCell
        let nameTextField = nameCell.textField
        guard let name = nameTextField!.text, !name.isEmpty
        else {
          self.saveButton.isEnabled = false
          return
        }
        saveButton.isEnabled = true
    }
    
    @objc func saveButtonAction() {

        if let idProfessor = selectedProfessorId {
            
            let nameCell = table.cellForRow(at: IndexPath(row: 0, section: 1)) as! EditProfessorTableViewCell
            var name = nameCell.textField.text
            var nameIsBlank = true
            for char in name! {
              if !char.isWhitespace {
                  nameIsBlank = false
              }
            }
            if nameIsBlank {
                name = Constants.professorNameDefault.localize()
            }
            let officeCell = table.cellForRow(at: IndexPath(row: 1, section: 1)) as! EditProfessorTableViewCell
            let office = officeCell.textField.text
            let emailCell = table.cellForRow(at: IndexPath(row: 2, section: 1)) as! EditProfessorTableViewCell
            let email = emailCell.textField.text

            if let imageName = imageName, let office = office, let email = email {
                
                databaseManager.editProfessor(idProfessor: idProfessor, name: name!, office: office, email: email, imageName: imageName)
                
                newEditedProfessor = Professor(name: name!, id: idProfessor, office: office, email: email, profilePic: imageName)
            }
            
            NotificationCenter.default.post(name: Notification.Name(Constants.editProfessorNotification), object: self)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didDeleteProfessor() {
        if selectedProfessorId != nil {
            NotificationCenter.default.post(name: Notification.Name(Constants.deleteProfessorNotification), object: self)
            self.dismiss(animated: true, completion: nil)
        }
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
        profileSelectorVC.originalImageName = editedProfessor.profilePic
        self.present(profileSelectorVC, animated: true)
    }
    
    func configureTable() {
        self.table.backgroundColor = Constants.cultured
        self.table.separatorColor = self.table.backgroundColor
    }
    
    func configureButtons() {
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: Constants.cancelButton.localize(), style: .plain, target: self, action: #selector(cancelButtonAction))
        cancelButton.tintColor = .white
        saveButton = UIBarButtonItem(title: Constants.saveButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        saveButton.tintColor = .white
        
        let navigItem: UINavigationItem = UINavigationItem(title: Constants.editProfessorViewControllerTitle.localize())
        navigItem.rightBarButtonItem = saveButton
        navigItem.leftBarButtonItem = cancelButton
        navigationBar.barTintColor = Constants.primaryBlue
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationBar.items = [navigItem]
    }

}

extension EditProfessorViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
            case 0:
                return 1
            case 1:
                return 3
            case 2:
                return 1
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
            imageProfessorCell.configure(imageName: editedProfessor.profilePic ?? Constants.profileImageDefault)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapEdit(recognizer:)))
            imageProfessorCell.profileImage.addGestureRecognizer(recognizer)
            return imageProfessorCell
        } else if indexPath.section == 2 {  // MARK: Delete Professor Button
            let deleteProfessorCell = tableView.dequeueReusableCell(withIdentifier: DeleteProfessorTableViewCell.identifier, for: indexPath) as! DeleteProfessorTableViewCell
            deleteProfessorCell.delegate = self
            return deleteProfessorCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.editProfessorCellId, for: indexPath) as! EditProfessorTableViewCell
            if indexPath.row == 0 {
                cell.configure(text: editedProfessor.name, placeholder: Constants.placeholderName.localize())
                cell.textField.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
                return cell
            } else if indexPath.row == 1 {
                cell.configure(text: editedProfessor.office ?? "", placeholder: Constants.placeholderOffice.localize())
                return cell
            } else {
                cell.configure(text: editedProfessor.email ?? "", placeholder: Constants.placeholderEmail.localize())
                return cell
            }
        }
    }

}

// MARK: - Delegates
extension EditProfessorViewController: DeleteProfessorCellDelegate {
    
    func didTapDeleteButton() {
        if let id = selectedProfessorId {
            databaseManager.deleteProfessor(id)
        }
        didDeleteProfessor()
    }
    
}


extension EditProfessorViewController: ProfessorsImageDelegate {
    
    func didChangeProfessorImage(imageName: String) {
        let imageCell = table.cellForRow(at: IndexPath(row: 0, section: 0)) as! ImageProfessorTableViewCell
        imageCell.configure(imageName: imageName)
        self.imageName = imageName
    }
    
}
