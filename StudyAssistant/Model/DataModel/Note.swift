//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation

class Note {
    
    enum NoteType: String {
        case image = "image"
        case pdf = "pdf"
    }
    
    // MARK: - Propiedades
    var title: String
    var id: String
    var url: String
    var type: NoteType
    var firestorePath: String?
    var connectionId: String?
    
    // MARK: - Constructor
    init (title: String, id: String, url: String, type: NoteType) {
        self.title = title
        self.id = id
        self.url = url
        self.type = type
    }
}
