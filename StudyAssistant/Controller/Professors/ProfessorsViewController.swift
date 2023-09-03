//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class ProfessorsViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var professors = [Professor]()
    var databaseManager = ProfessorsDBManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = Constants.professorsViewControllerTitle.localize()
        self.tabBarController?.tabBar.items?[2].title = Constants.professorsViewControllerTitle.localize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseManager.professorLoadDelegate = self
        
        // MARK: View Configuration
        configureNavBar()
        
        // MARK: Register Table Cells
        table.register(ProfessorTableViewCell.self, forCellReuseIdentifier: ProfessorTableViewCell.identifier)
        
        // MARK: Initial Data Load
        databaseManager.loadProfessors()
        
        // MARK: Observers (Edit & Delete Professor)
        NotificationCenter.default.addObserver(self, selector: #selector(didEditProfessor), name: Notification.Name(Constants.editProfessorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeleteProfessor), name: Notification.Name(Constants.deleteProfessorNotification), object: nil)
    }
    
    @objc func addButtonAction() {
        let addProfessorVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.addProfessorViewControllerId)) as! AddProfessorViewController
        addProfessorVC.professorDelegate = self
        self.present(addProfessorVC, animated: true)
    }
    
    @objc func didEditProfessor(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditProfessorViewController
        let editedProfessor = editVC.newEditedProfessor
        var indexEdited = -1
        if let idx = professors.firstIndex(where: {$0.id == editedProfessor.id}){
            professors[idx].name = editedProfessor.name
            professors[idx].office = editedProfessor.office
            indexEdited = idx
        }
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
        if indexEdited > -1 {
            let cell = table.cellForRow(at: IndexPath(row: indexEdited, section: 0)) as! ProfessorTableViewCell
            cell.updateImage(professorImage: editedProfessor.profilePic ?? Constants.profileImageDefault)
        }

    }
    
    @objc func didDeleteProfessor(notification: Notification) {
        // Update Local Data
        let editVC = notification.object as! EditProfessorViewController
        let deletedProfessorId = editVC.selectedProfessorId
        if let idx = professors.firstIndex(where: {$0.id == deletedProfessorId}){
            professors.remove(at: idx)
        }
        // Refresh View
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.barTintColor = Constants.primaryBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }
}

// MARK: - Table Delegates
extension ProfessorsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return professors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.professorCellId, for: indexPath) as! ProfessorTableViewCell
        cell.configure(professorName: professors[indexPath.row].name, professorOffice: professors[indexPath.row].office ?? "", professorImage: professors[indexPath.row].profilePic ?? Constants.profileImageDefault)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let professorDetailVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.professorDetailViewControllerId)) as! ProfessorDetailViewController
        professorDetailVC.selectedProfessorId = professors[indexPath.row].id
        professorDetailVC.selectedProfessorName = professors[indexPath.row].name
        self.navigationController?.pushViewController(professorDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Deleting Professor (Swipe Gesture)
        let deleteAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            
            let idProfessor = self.professors[indexPath.row].id
            self.databaseManager.deleteProfessor(idProfessor)

            if let idx = self.professors.firstIndex(where: {$0.id == idProfessor}){
                self.professors.remove(at: idx)
            }

            DispatchQueue.main.async {
                self.table.reloadData()
            }

            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

// MARK: - Delegates
extension ProfessorsViewController: ProfessorsDBManagerLoad {
    
    func didLoadProfessors(databaseManager: ProfessorsDBManager, data: [Professor]) {
        professors = data
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}

extension ProfessorsViewController: ProfessorsTableDelegate {
    
    func didAddProfessor(professorName: String, professorId: String, professorOffice: String, professorImage: String) {
        let addedProfessor = Professor(name: professorName, id: professorId)
        addedProfessor.profilePic = professorImage
        addedProfessor.office = professorOffice
        self.professors.insert(addedProfessor, at: 0)
        table.reloadData()
    }
    
}
