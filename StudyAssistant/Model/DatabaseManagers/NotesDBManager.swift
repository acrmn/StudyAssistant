//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

protocol NotesDBManagerLoad {
    func didLoadNotes(databaseManager: NotesDBManager, data: [Note])
    func didAddNote(databaseManager: NotesDBManager, document: DocumentSnapshot)
    
    //func didFailWithError(error: Error)
}

protocol KeywordsDBManagerLoad {
    func didLoadKeywords(databaseManager: NotesDBManager, data: [String])
}

protocol KeywordsDBManagerAdd {
    func didLoadAllKeywords(databaseManager: NotesDBManager, keywords: [String], documents:[QueryDocumentSnapshot], loadMore: Bool)
}

protocol ConnectionsDBManager {
    func didLoadSubjects(databaseManager: NotesDBManager, data: [Subject])
    func didLoadLessons(databaseManager: NotesDBManager, data: [Lesson])
}

class NotesDBManager {
    
    private let db = Constants.firestoreRef
    let storage = Constants.storageRef
    
    var noteLoadDelegate : NotesDBManagerLoad?
    var keywordLoadDelegate: KeywordsDBManagerLoad?
    var keywordLoadAllDelegate: KeywordsDBManagerAdd?
    var connectionDelegate: ConnectionsDBManager?
    
    func loadNotes(idSubject: String, idLesson: String) {
        var notes = [Note]()
        
        self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).whereField(Constants.fieldNoteIdSubject, isEqualTo: idSubject).whereField(Constants.fieldNoteIdLesson, isEqualTo: idLesson).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    notes.append(Note(title: document.get(Constants.fieldNoteTitle) as! String,
                                           id: document.documentID,
                                           url: document.get(Constants.fieldNoteURL) as! String,
                                           type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!))
                }
                self.noteLoadDelegate?.didLoadNotes(databaseManager: self, data: notes)
            }
        }
    }
    
    func newNote(imageData: Data, fileName: String, completion:@escaping((String?) -> () )) {
        //MARK: Se sube la imagen a Storage
        let objectRef = storage.reference().child(UserHelper.getUserEmail() + "/" + fileName)
        
        _ = objectRef.putData(imageData, metadata: nil) { (metadata, error) in
            //MARK: Se almacena la url del objeto multimedia de Storage en la base de datos Firestore
            objectRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print(error as Any)
                    completion(nil)
                    return
                }
                let imageURL = downloadURL.absoluteString
                completion(imageURL)
            }
        }
    }
    
    func saveNote(title: String, type: String, noteUrl: String, idSubject: String, idLesson: String) -> DocumentReference {
        //MARK: Se almacena el apunte en base de datos Firestore
        let refImage = self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document()

        refImage.setData([Constants.fieldNoteTitle:title,
                          Constants.fieldNoteURL:noteUrl,
                          Constants.fieldNoteType:type,
                          Constants.fieldNoteIdSubject:idSubject,
                          Constants.fieldNoteIdLesson:idLesson])
        
        refImage.updateData([Constants.fieldNoteSubjectLocation:idSubject]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        refImage.updateData([Constants.fieldNoteLessonLocation:idLesson]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return refImage
    }
    
    func deleteNote(idNote: String) {
        var url: String?
        var keywords = [String]()
        let groupKeywords = DispatchGroup()
        
        //MARK: Se obtienen las etiquetas del apunte, se retienen y se borran
        groupKeywords.enter()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionKeywords).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting keywords from note: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    keywords.append(document.get(Constants.fieldKeywordWord) as! String)
                    document.reference.delete()
                }
                groupKeywords.leave()
            }
        }
        
        //MARK: Se obtienen las conexiones del apunte y se borran
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionConnections).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting connections from note: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
        
        //MARK: Se elimina la referencia al apunte eliminado en las etiquetas en las que aparece
        groupKeywords.notify(queue: .main) {
            for key in keywords {
                self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(key).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents inside keyword collection: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            if(document.documentID == idNote){
                                document.reference.delete()
                            }
                        }
                    }
                }
            }
        }
        
        //MARK: Se elimina el apunte de base de datos
        let myGroup = DispatchGroup()
        myGroup.enter()
        self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).getDocument() { (document, error) in
            if let document = document, document.exists {
                url = document.get(Constants.fieldNoteURL) as? String
                document.reference.delete()
                myGroup.leave()
            } else {
                print("Note does not exist")
            }
        }

        //MARK: Se elimina el objeto multimedia de Storage
        myGroup.notify(queue: .main) {
            let noteRef = Storage.storage().reference(forURL: url ?? "")
            noteRef.delete { error in
              if let error = error {
                print("Error delete storage note \(error)")
              }
            }
        }
    }
    
    func editNote(idNote: String, newTitle: String) {
        self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).updateData([Constants.fieldNoteTitle:newTitle as String])
    }
    
    func loadKeywords(idNote: String) {
        var keywords = [String]()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionKeywords).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    keywords.append(document.get(Constants.fieldKeywordWord) as! String)
                }
                self.keywordLoadDelegate?.didLoadKeywords(databaseManager: self, data: keywords)
            }
        }
    }
    
    func deleteKeyword(idNote: String, keyword: String) {
        //MARK: Se elimina la etiqueta de la coleccion "keywords" del apunte (1)
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionKeywords).whereField(Constants.fieldKeywordWord, isEqualTo: keyword).getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
        //MARK: Se elimina el path del apunte de la coleccion "keyowrdXXX" (2)
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(keyword).document(idNote).delete()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(keyword).getDocuments() { querySnapShot, err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                if querySnapShot!.isEmpty {
                    self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionKeywords).document(keyword).delete()
                }
            }
        }
    }
    
    func configureBatch() -> Query {
        let batch = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionKeywords).order(by: Constants.fieldKeywordWord).limit(to: 10)
        return batch
    }
    
    func loadAllKeywords(batch: Query) {
        var keywords = [String]()
        var documents = [QueryDocumentSnapshot]()
        var loadMore = true
        
        batch.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if(querySnapshot?.isEmpty == false){
                    querySnapshot!.documents.forEach({ (document) in
                        keywords.append(document.get(Constants.fieldKeywordWord) as! String)
                        documents.append(document)
                    })
                } else {
                    loadMore = false
                }
                self.keywordLoadAllDelegate?.didLoadAllKeywords(databaseManager: self, keywords: keywords, documents: documents, loadMore: loadMore)
            }
        }
    }
    
    func connectNoteToKeyword(keyword: String, idNote: String, path: String) {
        let ref = self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(keyword).document(idNote)
        ref.setData([Constants.fieldKeywordNotePath: path])
    }
    
    func addKeywordToNote(idNote: String, keyword: String) -> String {
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionKeywords).document(keyword).setData([Constants.fieldKeywordWord: keyword])
        
        // Se añade la etiqueta a la coleccion "keywords" del apunte
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionKeywords).document()
        ref.setData([Constants.fieldKeywordWord: keyword])
        return db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).path
    }
    
    func loadQueriedNotes(keyword: String, idInitialNote: String, completion:@escaping ([String]?, [Note]?, Error?)->Void) {
        var queriedNotes = [Note]()
        var notePaths = [String]()
        let dispatchGroup = DispatchGroup()
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(keyword).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
                completion(nil, nil, err)
            } else {
                for document in querySnapshot!.documents {
                    let path = document.get(Constants.fieldKeywordNotePath) as! String
                    let ref = self.db.document(path)
                    
                    dispatchGroup.enter()
                    ref.getDocument() { (document, error) in
                        // Si el id es el mismo que el del apunte del que vengo se tarta del mismo apunte. No se muestra para conectar
                        if let document = document, document.exists {
                            if document.documentID != idInitialNote {
                                notePaths.append(path)
                                queriedNotes.append(Note(title: document.get(Constants.fieldNoteTitle) as! String,
                                                              id: document.documentID,
                                                              url: document.get(Constants.fieldNoteURL) as! String,
                                                              type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!))
                            }
                            dispatchGroup.leave()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(notePaths, queriedNotes, nil)
                }
            }
        }
    }
    
    func addConnection(idInitialNote: String, pathNote: String) -> DocumentReference {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idInitialNote).collection(Constants.collectionConnections).document()
        ref.setData([Constants.fieldKeywordNotePath: pathNote])
        return ref
    }
    
    func loadConnections(idNote: String, completion:@escaping ([Note]?, Error?)->Void) {
        let dispatchGroup = DispatchGroup()
        var notes = [Note]()
        self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionConnections).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
                completion(nil, err)
            } else {
                for document in querySnapshot!.documents {
                    // Se retiene el id de la conexion (para su eliminacion en un futuro)
                    let connectionId = document.documentID
                    // Se obtiene el apunte conectado en si y sus datos a traves de "notePath"
                    let path = document.get(Constants.fieldKeywordNotePath) as! String
                    let ref = self.db.document(path)
                    dispatchGroup.enter()
                    ref.getDocument() { (document, error) in
                        if let document = document, document.exists {
                            let note = (Note(title: document.get(Constants.fieldNoteTitle) as! String,
                                             id: document.documentID,
                                             url: document.get(Constants.fieldNoteURL) as! String,
                                             type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!))
                            note.connectionId = connectionId
                            notes.append(note)
                            dispatchGroup.leave()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(notes, nil)
                }
            }
        }
    }
    
    func deleteConnection(idNote: String, idConnection: String) {
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionConnections).document(idConnection).delete()
    }
    
    func loadSubjectsCollection() {
        var subjects = [Subject]()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    subjects.append(Subject(title: document.get(Constants.fieldSubjectTitle) as! String,
                                                 id: document.documentID))
                    self.connectionDelegate?.didLoadSubjects(databaseManager: self, data: subjects)
                }
            }
        }
    }
    
    func loadLessonsCollection(idSubject: String) {
        var lessons = [Lesson]()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).collection(Constants.collectionLessons).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    lessons.append((Lesson(title: document.get(Constants.fieldLessonTitle) as! String,
                                                id: document.documentID)))
                }
                self.connectionDelegate?.didLoadLessons(databaseManager: self, data: lessons)
            }
        }
    }
    
    func loadNotesToConnect(idSubject: String, idLesson: String, completion:@escaping ([Note]?, Error?)->Void) {
        var notes = [Note]()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).whereField(Constants.fieldNoteSubjectLocation, isEqualTo: idSubject).whereField(Constants.fieldNoteLessonLocation, isEqualTo: idLesson).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes: \(err)")
                completion(nil, err)
            } else {
                for document in querySnapshot!.documents {
                    let note = Note(title: document.get(Constants.fieldNoteTitle) as! String,
                                    id: document.documentID,
                                    url: document.get(Constants.fieldNoteURL) as! String,
                                    type: Note.NoteType(rawValue: document.get(Constants.fieldNoteType) as! String)!)
                    note.firestorePath = document.reference.path
                    notes.append(note)
                }
                completion(notes, nil)
            }
        }
    }

}
