//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import Foundation
import UIKit
import FirebaseStorage

extension UIImageView {
    func loadImage (storage: Storage, url: String){
        DispatchQueue.global().async {
            let path = storage.reference(forURL: url)
            path.downloadURL(completion: { (url, error) in
                print("loadImage")
                let data = NSData(contentsOf: url!)
                let image = UIImage(data: data! as Data)
                self.image = image
            })
        }
    }
}
