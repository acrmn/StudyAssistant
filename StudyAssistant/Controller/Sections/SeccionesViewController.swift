//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit


class SeccionesViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    
    var subjects = [Subject]()
    var section: Int?
    
    var databaseManager = SectionsDBManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title = Constants.subjectsViewControllerTitle.localize()
        self.tabBarController?.tabBar.items?[1].title = Constants.subjectsViewControllerTitle.localize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseManager.subjectsLoadDelegate = self
        
        // MARK: View Configuration
        configureNavBar()
        
        // MARK: Register Table Cells
        table.register(HeaderTableViewCell.self, forCellReuseIdentifier: HeaderTableViewCell.identifier)
        table.register(FooterTableViewCell.self, forCellReuseIdentifier: FooterTableViewCell.identifier)
        
        // MARK: Initial Data Load
        databaseManager.loadSubjects()
    }
    
    @objc func addButtonAction() {
        let addSubjectVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.addSubjectViewControllerId)) as! AddSubjectViewController
        addSubjectVC.subjectDelegate = self
        self.navigationController?.pushViewController(addSubjectVC, animated: true)
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.barTintColor = Constants.primaryBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }

}

extension SeccionesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return subjects.count
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let asignatura = subjects[section]
        if asignatura.expanded == true {
            return (asignatura.lessons?.count ?? 0) + 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        header.backgroundColor = .white
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: HeaderTableViewCell.identifier, for: indexPath) as! HeaderTableViewCell
                cell.set(asignatura: subjects[indexPath.section])
                cell.delegate = self
                section = indexPath.section
                return cell
        } else if indexPath.row == (subjects[indexPath.section].lessons?.count ?? 0) + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: FooterTableViewCell.identifier, for: indexPath) as! FooterTableViewCell
            cell.set(asignatura: subjects[indexPath.section])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.lessonCellId, for: indexPath) as! LessonTableViewCell
            cell.configure(lesson: subjects[indexPath.section].lessons?[indexPath.row - 1] ?? "", subject: subjects[indexPath.section])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.deselectRow(at: indexPath, animated: false)
        if indexPath.row == 0 || indexPath.row == (subjects[indexPath.section].lessons?.count ?? 0) + 1 {
            if let arrayLessons = subjects[indexPath.section].lessons, arrayLessons.count > 0{
                subjects[indexPath.section].expanded = !subjects[indexPath.section].expanded!
                table.reloadSections([indexPath.section], with: .none)
            }
        } else {
            let notesVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.notesViewControllerId)) as! NotesViewController
            notesVC.selectedSubject = subjects[indexPath.section].id
            notesVC.selectedLesson = subjects[indexPath.section].lessons?[indexPath.row - 1]
            let nombreLesson = subjects[indexPath.section].lessons?[indexPath.row - 1]
            if let valueIdLesson = subjects[indexPath.section].lessonsDictionary![nombreLesson!] {
                notesVC.idLesson = valueIdLesson
            }
            self.navigationController?.pushViewController(notesVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
    if indexPath.row != 0 &&  indexPath.row != (subjects[indexPath.section].lessons?.count ?? 0) + 1 {
        
        //MARK: Edit Lesson
        let editAction = UIContextualAction(style: .destructive, title: nil) { action, view, complete in
            var idLesson: String?
            var tittleLesson: String?

            if let lessons = self.subjects[indexPath.section].lessonsDictionary {
                for (key, value) in lessons {
                    if key == self.subjects[indexPath.section].lessons?[indexPath.row - 1] {
                        tittleLesson = key
                        idLesson = value
                        break
                    }
                }
            }
            
            // Input New Title
            let alertWindow = UIAlertController(title: Constants.addLessonModalTitle.localize(),
                                                message: Constants.addLessonModalBody.localize(),
                                                preferredStyle: .alert)
            alertWindow.addTextField(configurationHandler: { textField in
                textField.placeholder = Constants.addLessonModalTextField.localize()
            })
            
            // Save Button
            let addButton = UIAlertAction(title: Constants.saveButton.localize(), style: .default, handler: { (action) -> Void in
                if let name = alertWindow.textFields?[0].text {
                    var isDuplicate = false
                    for lesson in self.subjects[indexPath.section].lessons ?? [] {
                        if lesson == name {
                            isDuplicate = true
                            break
                        }
                    }
                    if isDuplicate { // Title already exists

                        let alertWindow = UIAlertController(title: Constants.duplicateLessonModalTitle.localize(),
                                                            message: Constants.duplicateLessonModalBody.localize(),
                                                            preferredStyle: .alert)

                        let OKButton = UIAlertAction(title: Constants.okButton, style: .cancel, handler: nil)

                        alertWindow.addAction(OKButton)

                        self.present(alertWindow, animated: true, completion: nil)
                        
                    } else {
                        
                    if let idLesson = idLesson, let titleLesson = tittleLesson {
                        
                        // Update Local ArrayLessons of Subject
                        if let idx = self.subjects[indexPath.section].lessons!.firstIndex(where: {$0 == titleLesson}){
                            self.subjects[indexPath.section].lessons![idx] = name
                        }
                        // Update DB
                        self.databaseManager.editLesson(idSubject: self.subjects[indexPath.section].id, idLesson: idLesson, lessonTitle: titleLesson, newLessonTitle: name, arrayLessons: self.subjects[indexPath.section].lessons!)

                    }
                            
                    // Update Local Lessons
                    let editedID = self.subjects[indexPath.section].id
                    self.subjects.removeAll(where: { $0.id == editedID })
                    self.databaseManager.loadLessonsArray(idSubject: editedID)
                    }
                }
            })
            // Cancel Button
            let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel, handler: nil)
            
            alertWindow.addAction(addButton)
            alertWindow.addAction(cancelButton)

            self.present(alertWindow, animated: true, completion: nil)
            complete(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemPurple
        
        //MARK: Delete Lesson
        let deleteAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            var idLesson: String?
            
            if let lessons = self.subjects[indexPath.section].lessonsDictionary {
                for (key, value) in lessons {
                    if key == self.subjects[indexPath.section].lessons?[indexPath.row - 1] {
                        idLesson = value
                        break
                    }
                }
            }
                
            // Update Local ArrayLessons of Subject
            let titleLesson = self.subjects[indexPath.section].lessons?[indexPath.row - 1]
            if let idx = self.subjects[indexPath.section].lessons!.firstIndex(where: {$0 == titleLesson}){
                self.subjects[indexPath.section].lessons?.remove(at: idx)
            }
            // Update DB
            self.databaseManager.deleteLesson(idSubject: self.subjects[indexPath.section].id, idLesson: idLesson!, arrayLessons: self.subjects[indexPath.section].lessons!, titleLesson: titleLesson!)

            // Refresh View
            self.subjects[indexPath.section].expanded = false
            DispatchQueue.main.async {
                self.table.reloadData()
            }
            
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    return nil
    }
    
}

// MARK: - Delegates
extension SeccionesViewController: SubjectsTableDelegate {
    
    // MARK: Added Subject
    func didAddSubject(subjectTitle: String, subjectId: String, red: CGFloat, green: CGFloat, blue: CGFloat) {
        let addedSubject = Subject(title: subjectTitle, id: subjectId)
        addedSubject.color = [Constants.redComp: red, Constants.greenComp: green, Constants.blueComp: blue]
        addedSubject.expanded = false
        self.subjects.insert(addedSubject, at: 0)
        table.beginUpdates()
        table.insertSections(IndexSet(integer: 0), with: .automatic)
        table.endUpdates()
    }
    
    // MARK: Edited Subject
    func didEditSubject(subjectTitle: String, subjectId: String, red: CGFloat, green: CGFloat, blue: CGFloat) {
        if let idx = subjects.firstIndex(where: {$0.id == subjectId}){
            subjects[idx].title = subjectTitle
            subjects[idx].color = [Constants.redComp: red, Constants.greenComp: green, Constants.blueComp: blue]
        }
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
}

extension SeccionesViewController: HeaderCellDelegate {
    
    //MARK: Add Lesson
    func tappedAddLessonOption(subject: Subject) {
        var isDuplicate = false
        
        // Input Title
        let alertWindow = UIAlertController(title: Constants.addLessonModalTitle.localize(),
                                            message: Constants.addLessonModalBody.localize(),
                                            preferredStyle: .alert)
        alertWindow.addTextField(configurationHandler: { textField in
            textField.placeholder = Constants.addLessonModalTextField.localize()
        })
        
        // Save Button
        let addButton = UIAlertAction(title: Constants.saveButton.localize(), style: .default, handler: { (action) -> Void in
            if let name = alertWindow.textFields?[0].text {
                if subject.lessons!.count > 0 {
                    for lesson in subject.lessons ?? [] {
                        if lesson == name {
                            isDuplicate = true
                            break
                        }
                    }
                }
                if isDuplicate { // Title already exists

                    let alertWindow = UIAlertController(title: Constants.duplicateLessonModalTitle.localize(),
                                                        message: Constants.duplicateLessonModalBody.localize(),
                                                        preferredStyle: .alert)
                    let OKButton = UIAlertAction(title: Constants.okButton, style: .cancel, handler: nil)
                    alertWindow.addAction(OKButton)
                    self.present(alertWindow, animated: true, completion: nil)
                    
                } else {
                    
                    // Update DB
                    let id = self.databaseManager.addLesson(idSubject: subject.id, titleLesson: name)
                    
                    // Update Local Data
                    subject.lessons?.append(name)
                    subject.lessonsDictionary?[name] = id
                    
                    // Refresh View
                    DispatchQueue.main.async {
                        self.table.reloadSections(IndexSet(integersIn: (self.section ?? 0)...(self.section ?? 0)), with: .automatic)
                    }
                }
            }
        })
        
        // Cancel Button
        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel, handler: nil)
        
        alertWindow.addAction(addButton)
        alertWindow.addAction(cancelButton)
        self.present(alertWindow, animated: true, completion: nil)
    }
    
    //MARK: Edit Subject
    func tappedEditSubjectOption(asignatura: Subject) {
        let addSubjectVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.addSubjectViewControllerId)) as! AddSubjectViewController
        addSubjectVC.subjectDelegate = self
        addSubjectVC.editedSubjectID = asignatura.id
        addSubjectVC.openedToEdit = true
        addSubjectVC.oldTitle = asignatura.title
        addSubjectVC.oldColor = UIColor(red: asignatura.color?[Constants.redComp] ?? 0.0,
                                        green: asignatura.color?[Constants.greenComp] ?? 0.0,
                                        blue: asignatura.color?[Constants.blueComp] ?? 0.0, alpha: 1)
        self.navigationController?.pushViewController(addSubjectVC, animated: true)
    }
    
    //MARK: Delete Subject
    func tappedDeleteSubjectOption(asignatura: Subject) {
        if asignatura.lessons?.count == 0 {
            // Update DB
            databaseManager.deleteSubject(idSubject: asignatura.id)

            // Update Local Data
            if let idx = subjects.firstIndex(where: { $0.id == asignatura.id }) {
                subjects.remove(at: idx)
            }
            // Refresh View
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        } else { // Subject Not Empty
            let alertWindow = UIAlertController(title: Constants.deleteSubjectDeniedModalTitle.localize(),
                                                message: Constants.deleteSubjectDeniedModalBody.localize(),
                                                preferredStyle: .alert)
            let okButton = UIAlertAction(title: Constants.okButton, style: .default, handler: nil)
            alertWindow.addAction(okButton)
            self.present(alertWindow, animated: true, completion: nil)
        }
    }
}

extension SeccionesViewController: SectionsDBManagerLoad {

    func didLoadSubjects(databaseManager: SectionsDBManager, data: [Subject]) {
        subjects = data
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    func didLoadLessonsArray(databaseManager: SectionsDBManager, data: Subject) {
        subjects.insert(data, at: 0)
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
}
