//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseFirestore

protocol NewKeywordsCellDelegate {
    func keywordsAdded(keyword: String)
}

class AddKeywordViewController: UIViewController {

    @IBOutlet weak var keywordLabel: UITextField!
    @IBOutlet weak var keywordsTable: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var newKeywordLabel: UILabel!
    @IBOutlet weak var yourKeywordsLabel: UILabel!
    
    var delegate: NewKeywordsCellDelegate?
    
    var idSubject: String?
    var idLesson: String?
    var idNote: String?
    var notePath: String?
    var keywords = [String]()
    var allKeywords = [String]()
    private let db = Constants.firestoreRef
    var batch: Query!
    var documents = [QueryDocumentSnapshot]()
    var loadMore = true
    
    var doneButton = UIBarButtonItem()
    
    var databaseManager = NotesDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseManager.keywordLoadAllDelegate = self

        batch = databaseManager.configureBatch()
        databaseManager.loadAllKeywords(batch: batch)
        
        configureNavBar()
        configureTextFields()
    }
    
    func configureNavBar() {
        keywordsTable.estimatedRowHeight = 0
        
        doneButton = UIBarButtonItem(title: Constants.doneButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        doneButton.tintColor = .white
        let navigItem: UINavigationItem = UINavigationItem(title: Constants.addKeywordViewControllerTitle.localize())
        navigItem.rightBarButtonItem = doneButton
        navigationBar.items = [navigItem]
        navigationBar.barTintColor = Constants.primaryBlue
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    func configureTextFields() {
        keywordLabel.placeholder = Constants.keywordPlaceholder.localize()
        newKeywordLabel.text = Constants.newKeywordLabel.localize()
        yourKeywordsLabel.text = Constants.yourKeywordLabel.localize()
    }
    
    @objc func saveButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func pagination() {
        batch = batch.start(afterDocument: documents.last!)
        databaseManager.loadAllKeywords(batch: batch)
    }
    
    @IBAction func addKeywordButtonAction(_ sender: Any) {
        addKeywordToNote { addedKeyword, path in
            if addedKeyword == nil && path == nil {
                // Duplicated Keyword
                let alertWindow = UIAlertController(title: Constants.duplicateKeywordModalTitle.localize(),
                                                    message: Constants.duplicateKeywordModalBody.localize(),
                                                    preferredStyle: .alert)
                let okButton = UIAlertAction(title: Constants.okButton, style: .cancel, handler: nil)
                alertWindow.addAction(okButton)
                self.present(alertWindow, animated: true, completion: nil)
            } else {
                self.keywordLabel.text? = ""
                let alertWindow = UIAlertController(title: Constants.addedKeywordModalTitle.localize(),
                                                    message: Constants.addedKeywordModalBody.localize(),
                                                    preferredStyle: .alert)
                let okButton = UIAlertAction(title: Constants.okButton, style: .default, handler: nil)
                alertWindow.addAction(okButton)
                self.present(alertWindow, animated: true, completion: nil)

                //MARK: Se añade a la coleccion "keywordXXX" un documento que represente el apunte (al que se esta añadiendo la etiqueta)
                self.databaseManager.connectNoteToKeyword(keyword: addedKeyword!, idNote: self.idNote!, path: path ?? "")
                
                self.delegate?.keywordsAdded(keyword: addedKeyword!)
            }
        }
    }
    
    func addKeywordToNote(completion:@escaping (String?, String?)->Void){
        if let keyword = keywordLabel.text {
            if keywords.contains(keyword) { //Note already has this keyword
                completion(nil, nil)
            } else {
                if let idNote = self.idNote {
                    notePath = self.databaseManager.addKeywordToNote(idNote: idNote, keyword: keyword)
                }
                // Keyword Added to Local Data
                keywords.append(keyword)
                completion(keyword, notePath)
            }
        }
    }
    
    @objc func hideKeyboard() {
      view.endEditing(true)
    }
    
}

extension AddKeywordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allKeywords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = keywordsTable.dequeueReusableCell(withIdentifier: Constants.keywordTableViewCellId, for: indexPath) as! KeywordTableViewCell
        cell.configure(with: allKeywords[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        keywordsTable.deselectRow(at: indexPath, animated: true)
        if keywords.contains(allKeywords[indexPath.row]) { //Note already has this keyword
            let alertWindow = UIAlertController(title: Constants.duplicateKeywordModalTitle.localize(),
                                                message: Constants.duplicateKeywordModalBody.localize(),
                                                preferredStyle: .alert)
            let okButton = UIAlertAction(title: Constants.okButton, style: .cancel, handler: nil)
            alertWindow.addAction(okButton)
            self.present(alertWindow, animated: true, completion: nil)
        } else {
            keywordLabel.text = allKeywords[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (loadMore == true && indexPath.row == allKeywords.count - 1) {
            pagination()
        }
    }
}

extension AddKeywordViewController: KeywordsDBManagerAdd {
    
    func didLoadAllKeywords(databaseManager: NotesDBManager, keywords: [String], documents: [QueryDocumentSnapshot], loadMore: Bool) {
        allKeywords += keywords
        self.documents += documents
        self.loadMore = loadMore
        self.keywordsTable.reloadData()
    }
}

