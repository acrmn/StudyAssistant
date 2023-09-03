//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

protocol ProfessorsDBManagerLoad {
    func didLoadProfessors(databaseManager: ProfessorsDBManager, data: [Professor])
}

protocol ProfessorsDBManagerDetail {
    func didLoadSingleProfessor(databaseManager: ProfessorsDBManager, data: Professor)
}

struct ProfessorsDBManager {
    
    private let db = Constants.firestoreRef
    let storage = Constants.storageRef
    
    var professorLoadDelegate : ProfessorsDBManagerLoad?
    var professorDetailDelegate: ProfessorsDBManagerDetail?
    
    func loadProfessors() {
        var professors = [Professor]()
        
        db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionProfessors).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting professors documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let professor = Professor(name: document.get(Constants.fieldProfessorName) as! String,
                                              id: document.documentID)
                    professor.email = document.get(Constants.fieldProfessorEmail) as? String
                    professor.office = document.get(Constants.fieldProfessorOffice) as? String
                    professor.profilePic = document.get(Constants.fieldProfessorImage) as? String
                    professors.append(professor)
                }
                professorLoadDelegate?.didLoadProfessors(databaseManager: self, data: professors)
            }
        }
    }
    
    func loadSingleProfessor(_ idProfessor: String) {
        var professor = Professor(name: "", id: "")
        
        let docRef = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionProfessors).document(idProfessor)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                professor = Professor(name: document.get(Constants.fieldProfessorName) as! String, id: document.documentID)
                professor.office = document.get(Constants.fieldProfessorOffice) as? String
                professor.email = document.get(Constants.fieldProfessorEmail) as? String
                professor.profilePic = document.get(Constants.fieldProfessorImage) as? String
                professorDetailDelegate?.didLoadSingleProfessor(databaseManager: self, data: professor)
            } else {
                print("Error getting professor document")
            }
        }
    }
    
    func editProfessor (idProfessor: String, name: String, office: String, email: String, imageName: String) {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionProfessors).document(idProfessor)
        
        ref.updateData([Constants.fieldProfessorName:name,
                     Constants.fieldProfessorOffice:office,
                     Constants.fieldProfessorEmail:email,
                        Constants.fieldProfessorImage: imageName])
    }
    
    func addProfessor (name: String, office: String, email: String, imageName: String) -> String {
        let ref = db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionProfessors).document()
        ref.setData([Constants.fieldProfessorName:name,
                     Constants.fieldProfessorOffice:office,
                     Constants.fieldProfessorEmail:email,
                     Constants.fieldProfessorImage: imageName])
        return ref.documentID
    }
    
    func deleteProfessor(_ idProfessor: String) {
        
        self.db.collection(Constants.collectionUsers).document(UserHelper.getUserEmail()).collection(Constants.collectionProfessors).document(idProfessor).delete(){ err in
            if let err = err {
                print("Error removing profesor: \(err)")
            }
        }
    }
    
    
    
}
