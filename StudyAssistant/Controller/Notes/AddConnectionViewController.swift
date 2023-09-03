//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import PDFKit

protocol ConnectionsTableDelegate {
    func didAddConnection(addedNotePath: String, connectionId: String)
}

class AddConnectionViewController: UIViewController {
    
    @IBOutlet weak var subjectsCollection: UICollectionView!
    @IBOutlet weak var lessonsCollection: UICollectionView!
    @IBOutlet weak var notesToConnectTableView: UITableView!
    
    var notes = [Note]()
    var subjects = [Subject]()
    var lessons = [Lesson]()
    var idInitialNote: String?
    var selectedSubject: String?
    var selectedLesson: String?

    var connectionDelegate: ConnectionsTableDelegate!
    private let db = Constants.firestoreRef
    let storage = Constants.storageRef
    
    var databaseManager = NotesDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseManager.connectionDelegate = self
        
        //MARK: Load Subjects Bar
        databaseManager.loadSubjectsCollection()
        //MARK: Load Lessons Bar
        if let subjectID = selectedSubject {
            databaseManager.loadLessonsCollection(idSubject: subjectID)
        }
        //MARK: Load Notes
        if let selectedSubject = self.selectedSubject, let selectedLesson = self.selectedLesson {
            databaseManager.loadNotesToConnect(idSubject: selectedSubject, idLesson: selectedLesson) { notes, error in
                if let error = error {
                    print(error)
                    return
                }
                self.notes = notes!
                DispatchQueue.main.async {
                    self.notesToConnectTableView.reloadData()
                }
            }
        }
    }
}

//MARK: - Collection Delegates
extension AddConnectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return subjects.count
        } else {
            return lessons.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.subjectsMenuCollectionViewCellId, for: indexPath) as! SubjectsMenuCollectionViewCell
            cell.configure(with: subjects[indexPath.row].title)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.lessonsMenuCollectionViewCellId, for: indexPath) as! LessonsMenuCollectionViewCell
            cell.configure(with: lessons[indexPath.row].title)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            selectedSubject = subjects[indexPath.row].id
            if let subjectID = selectedSubject {
                databaseManager.loadLessonsCollection(idSubject: subjectID)
            }
            notes = [Note]()
            DispatchQueue.main.async {
                self.notesToConnectTableView.reloadData()
            }
        } else {
            selectedLesson = lessons[indexPath.row].id
            notes = [Note]()
            if let selectedSubject = self.selectedSubject, let selectedLesson = self.selectedLesson {
                databaseManager.loadNotesToConnect(idSubject: selectedSubject, idLesson: selectedLesson) { notes, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.notes = notes!
                    DispatchQueue.main.async {
                        self.notesToConnectTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension AddConnectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var item = String()
        if collectionView.tag == 1 {
            item = subjects[indexPath.row].title
        } else {
            item = lessons[indexPath.row].title
        }
        let size = item.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        return size
    }
}

//MARK: - Table Delegates
extension AddConnectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesToConnectTableView.dequeueReusableCell(withIdentifier: Constants.totalNoteCellId, for: indexPath) as! TotalNoteCell
        
        if notes[indexPath.row].type == .pdf {
            let pdfUrl = URL(string: notes[indexPath.row].url)!
            let thumbnail = pdfThumbnail(url: pdfUrl, width: 240)
            cell.configurePdfCell(cardTitle: notes[indexPath.row].title, pathNote: notes[indexPath.row].firestorePath, cardImage: thumbnail ?? UIImage(), storage: storage, url: notes[indexPath.row].url)
            cell.delegate = self
            return cell
        } else {
            cell.configure(cardTitle: notes[indexPath.row].title, pathNote: notes[indexPath.row].firestorePath, storage: storage, url: notes[indexPath.row].url)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notesToConnectTableView.deselectRow(at: indexPath, animated: true)
        if notes[indexPath.row].type == .image {
            let imageViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.imageViewerViewControllerId) as! ImageViewerViewController
            imageViewerVC.noteSelected = notes[indexPath.row]
            self.navigationController?.pushViewController(imageViewerVC, animated: true)
        }
        if notes[indexPath.row].type == .pdf {
            let pdfViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.pdfViewerViewControllerId) as! PDFViewerViewController
            pdfViewerVC.noteSelected = notes[indexPath.row]
             self.navigationController?.pushViewController(pdfViewerVC, animated: true)
        }
    }
}

//MARK: - Delegates
extension AddConnectionViewController: TotalNoteCellDelegate {
    
    // MARK: Connect Note
    func didTapConnectButton(pathNote: String) {
        if let note = idInitialNote {
            self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(note).collection(Constants.collectionConnections).whereField(Constants.fieldConnectionNotePath, isEqualTo: pathNote).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting notes: \(err)")
                } else {
                    if let query = querySnapshot, !query.isEmpty { // Connection already exists
                        let alertWindow = UIAlertController(title: Constants.duplicateConnectionModalTitle.localize(),
                                                            message: Constants.duplicateConnectionModalBody.localize(),
                                                            preferredStyle: .alert)
                        let okButton = UIAlertAction(title: Constants.okButton, style: .cancel, handler: nil)
                        alertWindow.addAction(okButton)
                        self.present(alertWindow, animated: true, completion: nil)
                    } else {
                        let alertWindow = UIAlertController(title: Constants.confirmConnectionModalTitle.localize(),
                                                            message: Constants.confirmConnectionModalBody.localize(),
                                                            preferredStyle: .alert)
                        var connectionId = ""
                        let okButton = UIAlertAction(title: Constants.okButton, style: .default, handler: { (action) -> Void in
                            let ref = self.databaseManager.addConnection(idInitialNote: self.idInitialNote!, pathNote: pathNote)
                            connectionId = ref.documentID
                        })
                        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel, handler: nil)
                        alertWindow.addAction(okButton)
                        alertWindow.addAction(cancelButton)
                        self.present(alertWindow, animated: true, completion: nil)

                        self.connectionDelegate.didAddConnection(addedNotePath: pathNote, connectionId: connectionId)
                    }
                }
            }
        }
    }
    
}

extension AddConnectionViewController: ConnectionsDBManager {
    
    func didLoadSubjects(databaseManager: NotesDBManager, data: [Subject]) {
        subjects = data
        DispatchQueue.main.async {
            self.subjectsCollection.reloadData()
        }
    }
    
    func didLoadLessons(databaseManager: NotesDBManager, data: [Lesson]) {
        lessons = data
        DispatchQueue.main.async {
            self.lessonsCollection.reloadData()
        }
    }
}
