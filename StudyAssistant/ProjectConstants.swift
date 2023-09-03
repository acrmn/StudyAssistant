//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

struct Constants {
    
    // MARK: - Identificadores de Controladores
    static let addProfessorViewControllerId = "addProfessorVC"
    static let professorDetailViewControllerId = "professorDetailVC"
    static let profileSelectorViewControllerId = "profileSelectorVC"
    static let editProfessorViewControllerId = "editProfessorVC"
    static let addEventViewControllerId = "addEventVC"
    static let eventDetailViewControllerId = "eventDetailVC"
    static let editEventViewControllerId = "editEventVC"
    static let addSubjectViewControllerId = "addSubjectVC"
    static let notesViewControllerId = "notesVC"
    static let addKeywordViewControllerId = "addKeywordVC"
    static let queriedNotesViewControllerId = "queriedNotesVC"
    static let addConnectionViewControllerId = "addConnectionVC"
    static let imageViewerViewControllerId = "imageViewerVC"
    static let pdfViewerViewControllerId = "pdfViewerVC"
    static let keywordsViewControllerId = "keywordsVCBUENO"
    static let connectionsViewControllerId = "connectionsVC"

    // MARK: - Identificadores de Celdas
    static let professorCellId = "professorCell"
    static let professorFieldCellId = "professorFieldCell"
    static let addProfessorCellId = "addProfessorCell"
    static let editProfessorCellId = "editProfessorCell"
    static let professorTableViewCellId = "ProfessorTableViewCell"
    static let deleteProfessorTableViewCellId = "DeleteProfessorTableViewCell"
    static let imageProfessorTableViewCellId = "ImageProfessorTableViewCell"
    static let eventCellId = "eventCell"
    static let eventTableViewCellId = "EventTableViewCell"
    static let addEventCellId = "addEventCell"
    static let pfpCollectionViewCellId = "pfpCell"
    static let eventInfoTableViewCellId = "EventInfoTableViewCell"
    static let eventFieldCellId = "eventFieldCell"
    static let editEventCellId = "editEventCell"
    static let reminderTableViewCellId = "ReminderTableViewCell"
    static let deleteEventTableViewCellId = "DeleteEventTableViewCell"
    static let lessonCellId = "lessonCell"
    static let headerTableViewCellId = "HeaderTableViewCell"
    static let footerTableViewCellId = "FooterTableViewCell"
    static let simpleKeywordTableViewCellId = "simpleKeywordCell"
    static let keywordTableViewCellId = "keywordCell"
    static let queriedNoteCellId = "queriedNoteCell"
    static let connectedNoteCellId = "connectedNoteCell"
    static let subjectsMenuCollectionViewCellId = "subjectMenuCell"
    static let lessonsMenuCollectionViewCellId = "lessonMenuCell"
    static let totalNoteCellId = "totalNoteCell"
    static let noteCellId = "noteCell"
    
    // MARK: - Colores
    static let primaryBlue = UIColor(named: "PrimaryBlue")
    static let cultured = UIColor(named: "Cultured")
    static let cultured2 = UIColor(named: "Cultured2")
    static let salmon = UIColor(named: "Salmon")
    static let gunmetal = UIColor(named: "Gunmetal")

    // MARK: - Base de Datos
    static let firestoreRef = Firestore.firestore()
    static let storageRef = Storage.storage()
    
        //MARK: USERS
        static let collectionUsers = "users"
        
        //MARK: SUBJECTS
        static let collectionSubjects = "subjects"
        static let fieldSubjectTitle = "title"
        static let fieldSubjectColor = "color"
        static let subfieldSubjectRed = "redComponent"
        static let subfieldSubjectGreen = "greenComponent"
        static let subfieldSubjectBlue = "blueComponent"
        static let fieldSubjectArrayLessons = "arrayLessons"
        static let fieldSubjectMapLessons = "lessonsMap"
        
        //MARK: LESSONS
        static let collectionLessons = "lessons"
        static let fieldLessonTitle = "title"
        
        //MARK: NOTES
        static let collectionNotes = "notes"
        static let fieldNoteIdLesson = "idLesson"
        static let fieldNoteURL = "url"
        static let fieldNoteIdSubject = "idSubject"
        static let fieldNoteTitle = "title"
        static let fieldNoteType = "type"
        static let fieldNoteSubjectLocation = "locationMap.subjectLocation"
        static let fieldNoteLessonLocation = "locationMap.lessonLocation"
        
        //MARK: KEYWORDS
        static let collectionKeywords = "keywords"
        static let fieldKeywordWord = "word"
        static let fieldKeywordNotePath = "notePath"
        
        //MARK: CONNECTIONS
        static let collectionConnections = "connections"
        static let fieldConnectionNotePath = "notePath"
        
        //MARK: PROFESSORS
        static let collectionProfessors = "professors"
        static let fieldProfessorName = "name"
        static let fieldProfessorEmail = "email"
        static let fieldProfessorOffice = "office"
        static let fieldProfessorImage = "profileImage"
        
        //MARK: EVENTS
        static let collectionEvents = "events"
        static let fieldEventTitle = "title"
        static let fieldEventStartDate = "startDate"
        static let fieldEventLocation = "location"
        static let fieldEventStartTime = "startTime"
        static let fieldEventEndDate = "endDate"
        static let fieldEventEndTime = "endTime"
    
    // MARK: - Botones
    static let continueButton = "Continue"
    
    static let saveButton = "Save"
    static let cancelButton = "Cancel"
    static let editButton = "Edit"
    static let deleteProfessorButton = "Delete professor"
    static let deleteEventButton = "Delete event"
    static let okButton = "OK"
    static let doneButton = "Done"
    static let keywordsButton = "Keywords"
    static let connectionsButton = "Connections"
    static let connectButton = "Connect"
    
    static let addLessonOption = "Add lesson"
    static let editSubjectOption = "Edit subject"
    static let deleteSubjectOption = "Delete subject"
    static let importPDFOption = "Import PDF"
    static let importPhotoOption = "Import photo"
    static let takePhotoOption = "Take photo"
    static let editNoteOption = "Edit note"
    static let shareNoteOption = "Share note"
    static let deleteNoteOption = "Delete note"
    
    // MARK: - Ventanas Modales
    static let addLessonModalTitle = "New lesson"
    static let addLessonModalBody = "Set a new title for this lesson"
    static let addLessonModalTextField = "Lesson's title"
    static let duplicateLessonModalTitle = "Duplicate lesson"
    static let duplicateLessonModalBody = "The lesson already exists in this subject. Please provide a different title."
    static let uploadImageModalTitle = "New image"
    static let uploadImageModalBody = "Enter a title for the image"
    static let uploadImageModalTextField = "Image 01"
    static let uploadPDFModalTitle = "New file"
    static let uploadPDFModalBody = "Enter a title for the file"
    static let uploadPDFModalTextField = "File 01"
    static let duplicateKeywordModalTitle = "Duplicate keyword"
    static let duplicateKeywordModalBody = "This keyword is already in your note"
    static let addedKeywordModalTitle = "New keyword"
    static let addedKeywordModalBody = "The keyword was successfully added."
    static let duplicateConnectionModalTitle = "Duplicate connection"
    static let duplicateConnectionModalBody = "This connection already exists"
    static let confirmConnectionModalTitle = "New connection"
    static let confirmConnectionModalBody = "Do you want to connect this note?"
    static let deleteSubjectDeniedModalTitle = "Not empty subject"
    static let deleteSubjectDeniedModalBody = "In order to delete an entire subject it has to be empty. Please delete its lessons first."
    static let editNoteModalTitle = "New title"
    static let editNoteModalBody = "Set a new title for this note"
    static let editNoteModalTextField = "Note's title"
    
    // MARK: - Imagenes
    static let imageNote = UIImage(named: "image_icon")
    static let fileNote = UIImage(named: "file_icon")
    
    static let profileImage1 = "Professor_1"
    static let profileImage2 = "Professor_2"
    static let profileImage3 = "Professor_3"
    static let profileImage4 = "Professor_4"
    static let profileImage5 = "Professor_5"
    static let profileImage6 = "Professor_6"
    static let profileImage7 = "Professor_7"
    static let profileImage8 = "Professor_8"
    static let profileImage9 = "Professor_9"
    
    // MARK: - Localización
    static let tableLocalization = "Localization"
    
    // MARK: - UserDefaults
    static let emailKey = "userEmail"
    static let emailKeyEmpty = "noEmail"
    static let loginKey = "logged"
    
    static let loginSegue = "loginSegue"
    static let logoutSegue = "unwindSegue"
    
    // MARK: - Auxiliares Color
    static let colorPreviewText = "Color preview"
    static let colorPickButton = "Pick a color"
    static let colorPickerViewControllerTitle = "Select color"
    static let redComp = "redComponent"
    static let greenComp = "greenComponent"
    static let blueComp = "blueComponent"
    
    //MARK: - Auxiliares keyword
    static let keywordsViewControllerTitle = "Keywords"
    static let addKeywordViewControllerTitle = "Add keyword"
    static let keywordPlaceholder = "Keyword"
    static let newKeywordLabel = "NEW KEYWORD"
    static let yourKeywordLabel = "YOUR KEYWORDS"
    
    // MARK: - Auxiliares Profesor
    static let professorsViewControllerTitle = "Professors"
    static let editProfessorNotification = "editedProfessor"
    static let deleteProfessorNotification = "deletedProfessor"
    static let profileImageDefault = "Professor_Default"
    static let addProfessorViewControllerTitle = "Add professor"
    static let professorNameDefault = "New professor"
    static let placeholderOffice = "Office"
    static let placeholderName = "Name"
    static let placeholderEmail = "Email"
    static let editProfessorViewControllerTitle = "Edit professor"
    static let profileSelectorViewControllerTitle = "New profile image"
    
    // MARK: - Correo Electrónico
    static let emailSubjectDefault = "Study Assistant"
    static let emailBodyDefault = "Message generated from Study Assistant"
    
    // MARK: - Notificaciones Locales
    static let editEventNotification = "editedEvent"
    static let deleteEventNotification = "deletedEvent"
    static let eventNotificationTitle = "You have an event"
    
    // MARK: - Auxiliares Asignaturas
    static let subjectsViewControllerTitle = "Subjects"
    static let addSubjectViewControllerTitle = "Add subject"
    static let editSubjectViewControllerTitle = "Edit subject"
    
    
    // MARK: - Auxiliares Evento
    static let eventsViewControllerTitle = "Events"
    static let startDateDefault = "Start date"
    static let addEventViewControllerTitle = "Add event"
    static let placeholderTitle = "Title"
    static let placeholderLocation = "Location"
    static let dateFormat = "MMMM dd yyyy"
    static let timeFormat = "HH:mm"
    static let placeholderStartTime = "Start time"
    static let placeholderEndTime = "End time"
    static let placeholderStartDate = "Start date"
    static let placeholderEndDate = "End date"
    static let placeholderDateReminder = "Date of reminder"
    static let placeholderTimeReminder = "Time of reminder"
    static let placeholderReminder = "Reminder"
    static let editEventViewControllerTitle = "Edit event"
    static let eventNameDefault = "New event"
    static let eventScheduleReminder = "Schedule reminder"

    // MARK: - Auxiliares Apunte
    static let imageType = "image"
    static let pdfType = "pdf"

}
