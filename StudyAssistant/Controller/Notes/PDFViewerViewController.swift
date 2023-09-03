//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import PDFKit

class PDFViewerViewController: UIViewController {
    
    var noteSelected: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = noteSelected?.title
        
        let pdfView: PDFView = PDFView(frame: self.view.frame)
        view.addSubview(pdfView)
        
        if let url = noteSelected?.url {
            let pdfUrl = URL(string: url)!
            let document = PDFDocument(url: pdfUrl)
                pdfView.document = document
        }
        
        pdfView.autoScales = true
        pdfView.maxScaleFactor = 5.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
    }
    
}
