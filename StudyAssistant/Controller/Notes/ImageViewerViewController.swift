//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import CoreServices
import FirebaseStorage
import Photos

class ImageViewerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var noteSelected: Note?
    let storage = Constants.storageRef
    var reference: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = noteSelected?.title
        imageView.tintColor = UIColor.blue
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.isScrollEnabled = true
        
        if let imageUrl = noteSelected?.url {
            reference = storage.reference(forURL: imageUrl)
            reference.downloadURL(completion: { (url, error) in
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                self.imageView.image = image
            })
        }
    }
}

extension ImageViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
