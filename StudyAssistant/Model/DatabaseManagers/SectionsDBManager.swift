//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseStorage

protocol SectionsDBManagerLoad {
    func didLoadSubjects(databaseManager: SectionsDBManager, data: [Subject])
    func didLoadLessonsArray(databaseManager: SectionsDBManager, data: Subject)
}

protocol SectionsDBManagerDetail {
    func didLoadSingleSubject(databaseManager: SectionsDBManager, data: Subject)
}

struct SectionsDBManager {
    
    private let db = Constants.firestoreRef
    let storage = Constants.storageRef
    
    var subjectsLoadDelegate : SectionsDBManagerLoad?
    var subjectsDetailDelegate: SectionsDBManagerDetail?
    
    func loadSubjects() {
        var subjects = [Subject]()
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).order(by: Constants.fieldSubjectTitle).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting subjects documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let subject = Subject(title: document.get(Constants.fieldSubjectTitle) as! String, id: document.documentID)
                    if document.get(Constants.fieldSubjectArrayLessons) != nil { //si la asignatura tiene temas los guardo
                        subject.lessons = document.get(Constants.fieldSubjectArrayLessons) as? [String]
                    } else {
                        subject.lessons = [String]()
                    }
                    if document.get(Constants.fieldSubjectMapLessons) != nil {
                        subject.lessonsDictionary = document.get(Constants.fieldSubjectMapLessons) as? [String:String]
                    }
                    if document.get(Constants.fieldSubjectColor) != nil {
                        subject.color = document.get(Constants.fieldSubjectColor) as? [String:CGFloat]
                    }
                    subject.expanded = false
                    subjects.append(subject)
                }
                subjectsLoadDelegate?.didLoadSubjects(databaseManager: self, data: subjects)
            }
        }
    }
    
    func editLesson(idSubject: String, idLesson: String, lessonTitle: String, newLessonTitle: String, arrayLessons: [String]) {
        
        //MARK: Se actualiza el titulo en base de datos (1)
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).collection(Constants.collectionLessons).document(idLesson).updateData([Constants.fieldLessonTitle:newLessonTitle as String])
        
        //MARK: Se actualiza el "ArrayLessons" de la asignatura en base de datos (2)
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectArrayLessons:arrayLessons])
        
        //MARK: Se actualiza el "MapLessons" de la asignatura en base de datos (3)
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectMapLessons+"."+lessonTitle:FieldValue.delete()])
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectMapLessons+"."+newLessonTitle:idLesson])
        
    }
    
    func loadLessonsArray(idSubject: String) {
        var subject = Subject(title: "", id: "")
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).getDocument() { (document, error) in
            if let document = document, document.exists {
                subject = Subject(title: document.get(Constants.fieldSubjectTitle) as! String, id: document.documentID)
                if document.get(Constants.fieldSubjectArrayLessons) != nil {
                    subject.lessons = document.get(Constants.fieldSubjectArrayLessons) as? [String]
                } else {
                    subject.lessons = [String]()
                }
                if document.get(Constants.fieldSubjectMapLessons) != nil {
                    subject.lessonsDictionary = document.get(Constants.fieldSubjectMapLessons) as? [String:String]
                }
                if document.get(Constants.fieldSubjectColor) != nil {
                    subject.color = document.get(Constants.fieldSubjectColor) as? [String:CGFloat]
                }
                subject.expanded = false
                subjectsLoadDelegate?.didLoadLessonsArray(databaseManager: self, data: subject)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func deleteLesson(idSubject: String, idLesson: String, arrayLessons: [String], titleLesson: String) {
        
        let groupRetrieveNotes = DispatchGroup()
        var notesToDelete = [String]()
        
        //MARK: Se obtienen todos los apuntes del tema
        groupRetrieveNotes.enter()
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).whereField(Constants.fieldNoteIdLesson, isEqualTo: idLesson).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting notes to delete lesson: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    notesToDelete.append(document.documentID)
                }
                groupRetrieveNotes.leave()
            }
        }
        
        //MARK: Se borran todos los apuntes del tema obtenidos
        groupRetrieveNotes.notify(queue: .main){
            for idNote in notesToDelete {
                var url: String?
                var keywords = [String]()
                let groupKeywords = DispatchGroup()
                
                //MARK: Se guardan sus etiquetas y borran de una en una (1)
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
                
                //MARK: Se borran sus conexiones de una en una (2)
                db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).collection(Constants.collectionConnections).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting connections from note: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete()
                        }
                    }
                }
                
                //MARK: Se recorren los apuntes de cada etiqueta guardada y se borra el que esta siendo eliminado (3)
                groupKeywords.notify(queue: .main) {
                    for key in keywords {
                        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(key).getDocuments() { (querySnapshot, err) in
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
                
                //MARK: Se elimina el apunte de Firestore (4)
                let myGroup = DispatchGroup()
                myGroup.enter()
                db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionNotes).document(idNote).getDocument() { (document, error) in
                    if let document = document, document.exists {
                        // Se retiene la url del objeto en Storage para borrar el objeto multimedia
                        url = document.get(Constants.fieldNoteURL) as? String
                        document.reference.delete()
                        myGroup.leave()
                    } else {
                        print("Note does not exist")
                    }
                }

                //MARK: Se elimina el objeto multimedia del apunte en Storage (5)
                myGroup.notify(queue: .main) {
                    let noteRef = Storage.storage().reference(forURL: url ?? "")
                    noteRef.delete { error in
                      if let error = error {
                        print("Error delete storage note \(error)")
                      }
                    }
                }
            }
            
            //MARK: Se elimina el tema de base de datos
            db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).collection(Constants.collectionLessons).document(idLesson).delete()
            
            db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectArrayLessons:arrayLessons])
            
            //MARK: Se actualiza el "MapLessons" de base de datos
            db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectMapLessons+"."+titleLesson:FieldValue.delete()])
            
        }
    }
    
    func addLesson(idSubject: String, titleLesson: String) -> String {
        
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).collection(Constants.collectionLessons).document()
        let id = ref.documentID
        ref.setData([Constants.fieldLessonTitle:titleLesson as String])
        // Se añade el tema al "arrayLessons" de la asignatura a la que pertenezca
        let refSubject = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject)
        refSubject.updateData([Constants.fieldSubjectArrayLessons:FieldValue.arrayUnion([titleLesson])])
        // Se añade el tema al "MapLessons" de la asignatura a la que pertenezca
        refSubject.updateData([Constants.fieldSubjectMapLessons+"."+titleLesson:id]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        return id
        
    }
    
    func deleteSubject(idSubject: String) {
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).delete()
    }
    
    func editSubject(r: CGFloat, g: CGFloat, b: CGFloat, idSubject: String, titleSubject: String) {
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document(idSubject).updateData([Constants.fieldSubjectTitle:titleSubject, Constants.fieldSubjectColor:[Constants.subfieldSubjectRed:r, Constants.subfieldSubjectGreen:g, Constants.subfieldSubjectBlue:b]])
    }
    
    func addSubject(r: CGFloat, g: CGFloat, b: CGFloat, titleSubject: String) -> String {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionSubjects).document()
        ref.setData([Constants.fieldSubjectTitle:titleSubject, Constants.fieldSubjectColor:[Constants.subfieldSubjectRed:r, Constants.subfieldSubjectGreen:g, Constants.subfieldSubjectBlue:b]])
        
        return ref.documentID
    }
    
}
