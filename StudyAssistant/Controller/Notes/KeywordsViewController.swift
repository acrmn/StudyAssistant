//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

class KeywordsViewController: UIViewController {

    var idSubject: String?
    var idLesson: String?
    var idNote: String?
    var keywords = [String]()
    var lessonSeleccionada: String?
    
    @IBOutlet weak var keywordsTable: UITableView!
        
    var databaseManager = NotesDBManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseManager.keywordLoadDelegate = self
        
        // MARK: Initial Data Load
        if let idNote = idNote {
            databaseManager.loadKeywords(idNote: idNote)
        }
        
        //MARK: Navigation Bar Configuration
        configureNavBar()
    }
    
    func configureNavBar() {
        self.title = lessonSeleccionada
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }
    
    @objc func addButtonAction() {
        let addKeywordVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.addKeywordViewControllerId) as! AddKeywordViewController
        addKeywordVC.idSubject = idSubject
        addKeywordVC.idLesson = idLesson
        addKeywordVC.idNote = idNote
        addKeywordVC.keywords = keywords
        addKeywordVC.delegate = self
        self.present(addKeywordVC, animated: true)
    }
}

extension KeywordsViewController: NewKeywordsCellDelegate {
    func keywordsAdded(keyword: String) {
        self.keywords.append(keyword)
        DispatchQueue.main.async {
            self.keywordsTable.reloadData()
        }
    }
}

extension KeywordsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.simpleKeywordTableViewCellId, for: indexPath) as! SimpleKeywordTableViewCell
        cell.configure(keywordName: keywords[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let queriedNotesVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.queriedNotesViewControllerId) as! QueriedNotesViewController
        queriedNotesVC.keyword = keywords[indexPath.row]
        queriedNotesVC.idInitialNote = idNote
        queriedNotesVC.idLesson = idLesson
        queriedNotesVC.idSubject = idSubject
        self.present(queriedNotesVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //MARK: Delete Keyword (Swipe Gesture)
        let deleteAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in
            let keyword = self.keywords[indexPath.row]
            if let idNote = self.idNote {
                self.databaseManager.deleteKeyword(idNote: idNote, keyword: keyword)
                //MARK: Se actualiza el array local de etiquetas (3)
                if let index = self.keywords.firstIndex(of: keyword) {
                    self.keywords.remove(at: index)
                }
                DispatchQueue.main.async {
                    self.keywordsTable.reloadData()
                }
            }
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension KeywordsViewController: KeywordsDBManagerLoad {
    
    func didLoadKeywords(databaseManager: NotesDBManager, data: [String]) {
        keywords = data
        DispatchQueue.main.async {
            self.keywordsTable.reloadData()
        }
    }
}
