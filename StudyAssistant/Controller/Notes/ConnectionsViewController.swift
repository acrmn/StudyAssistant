



//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import PDFKit

class ConnectionsViewController: UIViewController {

    private let db = Constants.firestoreRef
    @IBOutlet weak var connectionsTable: UITableView!
    var connectedNotes = [Note]()
    var idSubject: String?
    var idLesson: String?
    var idNote: String?
    var lessonSeleccionada: String?
    
    let storage = Constants.storageRef
    var reference: StorageReference!
    
    var databaseManager = NotesDBManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lessonSeleccionada
        
        if let idNote = self.idNote {
            databaseManager.loadConnections(idNote: idNote) { connections, error in
                if let error = error {
                    print(error)
                    return
                }
                self.connectedNotes = connections!
                DispatchQueue.main.async {
                    self.connectionsTable.reloadData()
                }
            }
        }
        configureNavBar()
    }
    
    func configureNavBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonAction))
    }

    @objc func addButtonAction(){
        let addConnectionVC = (self.storyboard?.instantiateViewController(withIdentifier: Constants.addConnectionViewControllerId)) as! AddConnectionViewController
        addConnectionVC.idInitialNote = idNote
        addConnectionVC.selectedSubject = idSubject
        addConnectionVC.selectedLesson = idLesson
        addConnectionVC.connectionDelegate = self
        self.navigationController?.pushViewController(addConnectionVC, animated: true)
    }
}

// MARK: - Table Delegates
extension ConnectionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = connectionsTable.dequeueReusableCell(withIdentifier: Constants.connectedNoteCellId, for: indexPath) as! ConnectedNoteCell
        // Download Image from Storage (Thumbnail)
        var cardImage = UIImage()
        if connectedNotes[indexPath.row].type == .pdf {
            let pdfUrl = URL(string: connectedNotes[indexPath.row].url)!
            let pdf = PDFDocument(url: pdfUrl)
            let page = pdf?.page(at: 0)
            let size = CGSize(width: 100, height: 100)
            cardImage = page?.thumbnail(of: size, for: PDFDisplayBox.trimBox) ?? UIImage()
            
            let thumbnail = pdfThumbnail(url: pdfUrl, width: 240)
            cell.configurePdfCell(cardTitle: connectedNotes[indexPath.row].title, cardImage: thumbnail ?? UIImage(), storage: storage, url: connectedNotes[indexPath.row].url)
            return cell
        } else {
            cell.configure(cardTitle: connectedNotes[indexPath.row].title, cardImage: cardImage, storage: storage, url: connectedNotes[indexPath.row].url)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        connectionsTable.deselectRow(at: indexPath, animated: false)
        if connectedNotes[indexPath.row].type == .image {
            let imageViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.imageViewerViewControllerId) as! ImageViewerViewController
            imageViewerVC.noteSelected = connectedNotes[indexPath.row]
            self.navigationController?.pushViewController(imageViewerVC, animated: true)
        }
        if connectedNotes[indexPath.row].type == .pdf {
            let pdfViewerVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.pdfViewerViewControllerId) as! PDFViewerViewController
            pdfViewerVC.noteSelected = connectedNotes[indexPath.row]
             self.navigationController?.pushViewController(pdfViewerVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //MARK: Delete Connection (Swipe Getsure)
        let deleteAction = UIContextualAction(style: .normal, title: nil) { action, view, complete in

            if let note = self.idNote, let id = self.connectedNotes[indexPath.row].connectionId, !id.isEmpty {
                // Delete Data from DB
                self.databaseManager.deleteConnection(idNote: note, idConnection: id)
                // Delete Local Data
                if let idx = self.connectedNotes.firstIndex(where: { $0.connectionId ==  id}) {
                    self.connectedNotes.remove(at: idx)
                }
            }
            // Refresh View
            DispatchQueue.main.async {
                self.connectionsTable.reloadData()
            }
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Delegates
extension ConnectionsViewController: ConnectionsTableDelegate {
    
    // MARK: Add Connection TODO usar dataManager para traer esta note individual
    func didAddConnection(addedNotePath: String, connectionId: String) {
        // connectionId: id del documento de la conexion en base de datos
        
        // Se obtiene el apunte asociado al "notePath" de la conexion que se acaba de añadir
        var connectedNote = Note(title: "", id: "", url: "", type: .image)
        let dispatchGroupConnection = DispatchGroup()
        let ref = self.db.document(addedNotePath)
        
        dispatchGroupConnection.enter()
        ref.getDocument() { (document, error) in
            if let document = document, document.exists {
                connectedNote = (Note(title: document.get(Constants.fieldNoteTitle) as! String,
                                      id: document.documentID,
                                      url: document.get(Constants.fieldNoteURL) as! String,
                                      type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!))
                connectedNote.connectionId = connectionId
                self.connectedNotes.append(connectedNote)
                dispatchGroupConnection.leave()
            } else {
                print("Document does not exist")
            }
        }
        dispatchGroupConnection.notify(queue: .main) {
            self.connectionsTable.reloadData()
        }
    }
}

func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
  guard let data = try? Data(contentsOf: url),
  let page = PDFDocument(data: data)?.page(at: 0) else {
    return nil
  }

  let pageSize = page.bounds(for: .mediaBox)
  let pdfScale = width / pageSize.width
  let scale = UIScreen.main.scale * pdfScale
  let screenSize = CGSize(width: pageSize.width * scale,
                          height: pageSize.height * scale)

  return page.thumbnail(of: screenSize, for: .mediaBox)
}
