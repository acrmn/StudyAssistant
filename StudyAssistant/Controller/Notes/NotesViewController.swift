//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import CoreServices
import FirebaseStorage
import Photos
import FirebaseFirestore
import PDFKit
import grpc

class NotesViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate {
    
    var noteUrl: String?
    var databaseManager = NotesDBManager()
    let storage = Constants.storageRef
    var reference: StorageReference!
    var imageToShare: UIImage?
    var imageFromCamera: Bool?
    var selectedSubject: String?
    var selectedLesson: String?
    var idLesson: String?
    var notes = [Note]()

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notesTableView: UITableView!
    
    let photoPicker = UIImagePickerController()
    let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeFolder as String], in: .open)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseManager.noteLoadDelegate = self
        self.title = selectedLesson
        
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
        //MARK: Initial Data Load
        if let subject = selectedSubject, let lesson = idLesson {
            databaseManager.loadNotes(idSubject: subject, idLesson: lesson)
        }
        
        //MARK: Menu Configuration
        configureMenu()
    }
    
    func configureMenu() {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: Constants.importPDFOption.localize(), image: UIImage(systemName: "doc")) { action in
                self.documentPicker.allowsMultipleSelection = false
                self.documentPicker.delegate = self
                self.present(self.documentPicker, animated: true)
            },
            UIAction(title: Constants.importPhotoOption.localize(), image: UIImage(systemName: "photo")) { action in
                self.imageFromCamera = false
                self.photoPicker.sourceType = .photoLibrary
                self.photoPicker.delegate = self
                self.present(self.photoPicker, animated: true)
            },
            UIAction(title: Constants.takePhotoOption.localize(), image: UIImage(systemName: "camera")) { action in
                self.imageFromCamera = true
                self.photoPicker.sourceType = .camera
                self.photoPicker.delegate = self
                self.present(self.photoPicker, animated: true)
            }
        ])
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: menu)
    }
}

//MARK: - Table Delegates
extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: Constants.noteCellId, for: indexPath) as! NoteCell
        cell.configure(cardTitle: notes[indexPath.row].title, idNote: notes[indexPath.row].id, type: notes[indexPath.row].type.rawValue)
        cell.delegate = self
        cell.note = notes[indexPath.row]
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notesTableView.deselectRow(at: indexPath, animated: true)
        
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //MARK: Delete Note (Swipe Getsure)
        if editingStyle == .delete {
            databaseManager.deleteNote(idNote: notes[indexPath.row].id)
            // Update Local Data
            if let idx = notes.firstIndex(where: { $0.id == notes[indexPath.row].id }) {
                notes.remove(at: idx)
            }
            // Refresh View
            DispatchQueue.main.async {
                self.notesTableView.reloadData()
            }
        }
    }
}

// MARK: - Cell Delegates
extension NotesViewController: NoteCellDelegate {
    
    // MARK: Edit Note
    func didTapEditNoteButton(idNote: String) {
        let alertWindow = UIAlertController(title: Constants.editNoteModalTitle.localize(),
                                            message: Constants.editNoteModalBody.localize(),
                                            preferredStyle: .alert)
        alertWindow.addTextField(configurationHandler: { textField in
            textField.placeholder = Constants.editNoteModalTextField.localize()
        })
        
        let addButton = UIAlertAction(title: Constants.saveButton.localize(), style: .default, handler: { (action) -> Void in
            if let name = alertWindow.textFields?[0].text {
                // Update DB
                self.databaseManager.editNote(idNote: idNote, newTitle: name)
                // Update Local Data
                if let idx = self.notes.firstIndex(where: {$0.id == idNote}){
                    self.notes[idx].title = name
                }
                DispatchQueue.main.async {
                    self.notesTableView.reloadData()
                }
            }
        })
        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel, handler: nil)
        alertWindow.addAction(addButton)
        alertWindow.addAction(cancelButton)
        self.present(alertWindow, animated: true, completion: nil)
    }
    
    // MARK: Share Note
    func didTapShareNoteButton(note: Note) {
        if note.type == .image {
            let imageUrl = note.url
            reference = storage.reference(forURL: imageUrl)
            reference.downloadURL(completion: { (url, error) in
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                self.imageToShare = image
                if let imageToShare = self.imageToShare {
                    let shareSheetVC = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
                    self.present(shareSheetVC, animated: true)
                }
            })
        } else {
            let url = note.url
            let pdfUrl = URL(string: url)!
            let document = PDFDocument(url: pdfUrl)?.dataRepresentation()
            if document == nil {
                print("Document null")
            }
            if let document = document {
                let shareSheetVC = UIActivityViewController(activityItems: [document], applicationActivities: nil)
                self.present(shareSheetVC, animated: true)
            }
        }
    }
    
    func didTapDeleteNoteButton(idNote: String) {
        //MARK: Delete Note (Button)
        databaseManager.deleteNote(idNote: idNote)
        // Update Local data
        if let idx = notes.firstIndex(where: { $0.id == idNote }) {
            notes.remove(at: idx)
        }
        // Refresh View
        DispatchQueue.main.async {
            self.notesTableView.reloadData()
        }
    }
    
    // MARK: Show Keywords
    func didTapKeywordsButton(idNote: String, lessonTitle: String) {
        let keywordsVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.keywordsViewControllerId) as! KeywordsViewController
        keywordsVC.idSubject = selectedSubject
        keywordsVC.idLesson = idLesson
        keywordsVC.idNote = idNote
        keywordsVC.lessonSeleccionada = lessonTitle
        self.navigationController?.pushViewController(keywordsVC, animated: true)
    }
    
    // MARK: Show Connections
    func didTapConnectionsButton(idNote: String, lessonTitle: String) {
        let connectionsVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.connectionsViewControllerId) as! ConnectionsViewController
        connectionsVC.idSubject = selectedSubject
        connectionsVC.idLesson = idLesson
        connectionsVC.idNote = idNote
        connectionsVC.lessonSeleccionada = lessonTitle
        self.navigationController?.pushViewController(connectionsVC, animated: true)
    }
}

//MARK: - Image Picker Delegate
extension NotesViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var fileName: String = ""
        var imageData: Data?
        
        if (picker.sourceType == UIImagePickerController.SourceType.camera) {
            //MARK: Photo from Camera
            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            if let image = selectedImage {
                let imgName = UUID().uuidString
                let documentDirectory = NSTemporaryDirectory()
                let localPath = documentDirectory.appending(imgName)
                let data = image.jpegData(compressionQuality: 1.0)! as NSData
                data.write(toFile: localPath, atomically: true)
                let photoURL = URL.init(fileURLWithPath: localPath)
                fileName = photoURL.lastPathComponent
                imageData = image.jpegData(compressionQuality: 1.0)
            }
        } else {
            //MARK: Photo from Photo Library
            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                    fileName = url.lastPathComponent
            }
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imageData = image?.jpegData(compressionQuality: 1.0)

            self.photoPicker.dismiss(animated: true, completion: nil)
        }

        let alertWindow = UIAlertController(title: Constants.uploadImageModalTitle.localize(),
                                            message: Constants.uploadImageModalBody.localize(),
                                            preferredStyle: .alert)
        alertWindow.addTextField(configurationHandler: { textField in
            textField.placeholder = Constants.uploadImageModalTextField.localize()
        })
            
        let saveButton = UIAlertAction(title: Constants.saveButton.localize(), style: .default, handler: { (action) -> Void in
            //MARK: Upload Photo to Storage
            self.databaseManager.newNote(imageData: imageData!, fileName: fileName) { url in
                self.noteUrl = url
                let refImage = self.databaseManager.saveNote(title: alertWindow.textFields![0].text ?? "New Image", type: Constants.imageType, noteUrl: url!, idSubject: self.selectedSubject!, idLesson: self.idLesson!)
                // Update Local Data
                self.notes.append(Note(title: alertWindow.textFields![0].text ?? "New Image",
                                       id: refImage.documentID,
                                       url: self.noteUrl!,
                                       type: Note.NoteType(rawValue: Constants.imageType)!))
                DispatchQueue.main.async {
                    self.notesTableView.reloadData()
                }
                
            }
        })
        
        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel) { (action) -> Void in
        }
        alertWindow.addAction(saveButton)
        alertWindow.addAction(cancelButton)
        self.present(alertWindow, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        photoPicker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Document Picker Delegate
extension NotesViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var fileName = ""
        
        if let urlAccessible = urls.first, urlAccessible.startAccessingSecurityScopedResource() {
            fileName = urls[0].lastPathComponent
        }
        documentPicker.dismiss(animated: true, completion: nil)
        
        let alertWindow = UIAlertController(title: Constants.uploadPDFModalTitle.localize(),
                                            message: Constants.uploadPDFModalBody.localize(),
                                            preferredStyle: .alert)
        alertWindow.addTextField(configurationHandler: { textField in
            textField.placeholder = Constants.uploadPDFModalTextField.localize()
        })
        
        let saveButton = UIAlertAction(title: Constants.saveButton.localize(), style: .default, handler: { (action) -> Void in
            
            if let pdfData = NSData(contentsOf: urls[0]) as Data? {
                //MARK: Upload PDF to Storage
                self.databaseManager.newNote(imageData: pdfData, fileName: fileName) { url in
                    self.noteUrl = url
                    let refDoc = self.databaseManager.saveNote(title: alertWindow.textFields![0].text ?? "New Document", type: Constants.pdfType, noteUrl: url!, idSubject: self.selectedSubject!, idLesson: self.idLesson!)
                    // Update Local Data
                    self.notes.append(Note(title: alertWindow.textFields![0].text ?? "New Document",
                                           id: refDoc.documentID,
                                           url: self.noteUrl!,
                                           type: Note.NoteType(rawValue: Constants.pdfType)!))
                    DispatchQueue.main.async {
                        self.notesTableView.reloadData()
                    }
                }
            }
        })

        let cancelButton = UIAlertAction(title: Constants.cancelButton.localize(), style: .cancel) { (action) -> Void in
        }

        alertWindow.addAction(saveButton)
        alertWindow.addAction(cancelButton)
        self.present(alertWindow, animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        documentPicker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Database Manager Delegate
extension NotesViewController: NotesDBManagerLoad {

    func didLoadNotes(databaseManager: NotesDBManager, data: [Note]) {
        notes = data
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.loadingView.isHidden = true
            self.notesTableView.reloadData()
        }
    }
    
    func didAddNote(databaseManager: NotesDBManager, document: DocumentSnapshot) {
        notes.append(Note(title: document.get(Constants.fieldNoteTitle) as! String,
                               id: document.documentID,
                               url: document.get(Constants.fieldNoteURL) as! String,
                               type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!))
        DispatchQueue.main.async {
            self.notesTableView.reloadData()
        }
    }
}
