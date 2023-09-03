//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import MessageUI

class ProfessorDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var table: UITableView!
    
    var databaseManager = ProfessorsDBManager()
    var controllerM: CustomMailComposerViewController?
    
    var professor = Professor(name: "", id: "")
    var selectedProfessorId: String?
    var selectedProfessorName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedProfessorName
        
        databaseManager.professorDetailDelegate = self
        
        // MARK: Initial Data Load
        if let professorID = selectedProfessorId {
            databaseManager.loadSingleProfessor(professorID)
        }
        
        // MARK: View Configuration
        configureTable()
        configureButtons()
        
        // MARK: Observers (Edit & Delete Professor)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditProfessor), name: Notification.Name(Constants.editProfessorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteProfessor), name: Notification.Name(Constants.deleteProfessorNotification), object: nil)
        
        // MARK: Register Table Cells
        table.register(ImageProfessorTableViewCell.nib(), forCellReuseIdentifier: ImageProfessorTableViewCell.identifier)

    }
    
    @objc func editButtonAction() {
        let editProfessorVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.editProfessorViewControllerId)) as! EditProfessorViewController
        editProfessorVC.selectedProfessorId = selectedProfessorId
        editProfessorVC.editedProfessor = self.professor
        editProfessorVC.imageName = self.professor.profilePic
        self.present(editProfessorVC, animated: true)
    }
    
    @objc func didDeleteProfessor(notification: Notification) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didEditProfessor(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditProfessorViewController
        self.professor = editVC.newEditedProfessor
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    func configureTable() {
        self.table.backgroundColor = Constants.cultured
        self.table.separatorColor = self.table.backgroundColor
    }
    
    func configureButtons() {
        let editButton: UIBarButtonItem = UIBarButtonItem(title: Constants.editButton.localize(), style: .plain, target: self, action: #selector(editButtonAction))
        editButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    // MARK: Mail Handler (Dismiss Mail)
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}

// MARK: - Table Delegates
extension ProfessorDetailViewController: UITableViewDelegate, UITableViewDataSource {

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
        if indexPath.row == 2 {
            //MARK: Send email
            var recipientsEmail = [String]()
            recipientsEmail.append(professor.email ?? "")
            if MFMailComposeViewController.canSendMail() {
                controllerM = CustomMailComposerViewController(recipients: recipientsEmail,
                                                               subject: Constants.emailSubjectDefault.localize(),
                                                               body: Constants.emailBodyDefault.localize(),
                                                               messageBodyIsHTML: false)
                controllerM?.mailComposeDelegate = self
                if let mailController = controllerM {
                    self.present(mailController, animated: true)
                }

            } else {    // Use case: Simulator
                print("Error. Imposible enviar email.")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let imageProfessorCell = tableView.dequeueReusableCell(withIdentifier: ImageProfessorTableViewCell.identifier, for: indexPath) as! ImageProfessorTableViewCell
            imageProfessorCell.configure(imageName: professor.profilePic ?? Constants.profileImageDefault)
            return imageProfessorCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.professorFieldCellId, for: indexPath) as! ProfessorDetailTableViewCell
            if indexPath.row == 0 {
                cell.configure(data: professor.name, clickable: false)
                return cell
            } else if indexPath.row == 1 {
                cell.configure(data: professor.office ?? "", clickable: false)
                return cell
            } else {
                cell.configure(data: professor.email ?? "", clickable: true)
                return cell
            }
        }
    }

}

// MARK: - Delegates
extension ProfessorDetailViewController: ProfessorsDBManagerDetail {
    
    func didLoadSingleProfessor(databaseManager: ProfessorsDBManager, data: Professor) {
        professor = data
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}
