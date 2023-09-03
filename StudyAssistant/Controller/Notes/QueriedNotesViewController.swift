//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseFirestore
import PDFKit
import FirebaseStorage

class QueriedNotesViewController: UIViewController {

    private let db = Constants.firestoreRef
    @IBOutlet weak var queriedNotesTableView: UITableView!
    var queriedNotes = [Note]()
    var keyword: String?
    var notePaths = [String]()
    var idInitialNote: String?
    var idSubject: String?
    var idLesson: String?
    
    let storage = Constants.storageRef
    var reference: StorageReference!
    
    var databaseManager = NotesDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let keyword = keyword {
            databaseManager.loadQueriedNotes(keyword: keyword, idInitialNote: idInitialNote!) { paths, notes, error in
                if let error = error {
                    print(error)
                    return
                }
                self.notePaths = paths!
                self.queriedNotes = notes!
                DispatchQueue.main.async {
                    self.queriedNotesTableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Table Delegates
extension QueriedNotesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queriedNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = queriedNotesTableView.dequeueReusableCell(withIdentifier: Constants.queriedNoteCellId, for: indexPath) as! QueriedNoteCell
        // Download Image from Storage (Thumbnail)
        var cardImage = UIImage()
        if queriedNotes[indexPath.row].type == .pdf {
            let pdfUrl = URL(string: queriedNotes[indexPath.row].url)!
            let pdf = PDFDocument(url: pdfUrl)
            let page = pdf?.page(at: 0)
            let size = CGSize(width: 100, height: 100)
            cardImage = page?.thumbnail(of: size, for: PDFDisplayBox.trimBox) ?? UIImage()
            let thumbnail = pdfThumbnail(url: pdfUrl, width: 240)
            cell.configurePdfCell(cardTitle: queriedNotes[indexPath.row].title, pathNote: notePaths[indexPath.row], cardImage: thumbnail ?? UIImage(), storage: storage, url: queriedNotes[indexPath.row].url)
            cell.delegate = self
            return cell
        } else {
            cell.configure(cardTitle: queriedNotes[indexPath.row].title, pathNote: notePaths[indexPath.row], cardImage: cardImage, storage: storage, url: queriedNotes[indexPath.row].url)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        queriedNotesTableView.deselectRow(at: indexPath, animated: true)
        
        if queriedNotes[indexPath.row].type == .image {
            let imageViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.imageViewerViewControllerId) as! ImageViewerViewController
            imageViewerVC.noteSelected = queriedNotes[indexPath.row]
            imageViewerVC.modalPresentationStyle = .automatic
            self.present(imageViewerVC, animated: true)
        }
        if queriedNotes[indexPath.row].type == .pdf {
            let pdfViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.pdfViewerViewControllerId) as! PDFViewerViewController
            pdfViewerVC.noteSelected = queriedNotes[indexPath.row]
             self.navigationController?.pushViewController(pdfViewerVC, animated: true)
        }
    }
}

// MARK: - Delegates
extension QueriedNotesViewController: QueriedNoteCellDelegate {
    
    // MARK: Connect Note
    func didTapConnectButton(pathNote: String) {
        if let note = idInitialNote {
            self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(note).collection(Constants.collectionConnections).whereField(Constants.fieldKeywordNotePath, isEqualTo: pathNote).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting notes: \(err)")
                } else {
                    if let query = querySnapshot, !query.isEmpty { // Connection Already Exists
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
                        let okButton = UIAlertAction(title: Constants.okButton, style: .default, handler: { (action) -> Void in
//                            let ref = self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(self.idInitialNote!).collection(Constants.collectionConnections).document()
//                            ref.setData([Constants.fieldKeywordNotePath: pathNote])
                            _ = self.databaseManager.addConnection(idInitialNote: self.idInitialNote!, pathNote: pathNote)
                        })
                        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel, handler: nil)
                        alertWindow.addAction(okButton)
                        alertWindow.addAction(cancelButton)
                        self.present(alertWindow, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

