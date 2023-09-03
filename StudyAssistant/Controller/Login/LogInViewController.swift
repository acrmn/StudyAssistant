//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class LogInViewController: UIViewController {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var salmonView: UIView!
    
    private let db = Constants.firestoreRef
    
    override func viewDidLoad() {
        super.viewDidLoad()
        salmonView.layer.cornerRadius = 35.0
        salmonView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // MARK: Google Sign In
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        // MARK: Adapt Font Size
        let deviceType = UIDevice.current.deviceType
        switch deviceType {
            case .iPhone_SE_1st_Gen:
            titleLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 13)
            case .iPhone_SE_2nd_Gen:
                titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 15)
            case .iPhone_11:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_8_Plus:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_7_Plus:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_13_Mini:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_11_Pro:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_13:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_11_Pro_Max:
                titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 17)
            case .iPhone_13_Pro_Max:
                titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 20)
            default:
                titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
                nameLabel.font = UIFont.systemFont(ofSize: 12)
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
}

extension LogInViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil {
            let defaults = UserDefaults.standard
            // Configure User Defaults
            defaults.set(user.profile.email, forKey: Constants.emailKey)
            defaults.set(true, forKey: "logged")
            
            var registeredUser = false
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            db.collection(Constants.collectionUsers).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting users documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        if document.documentID == user.profile.email {
                            // User already registered
                            registeredUser = true
                        }
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if registeredUser == false {
                    // New User (Registration)
                    if let email = user.profile.email {
                        self.db.collection(Constants.collectionUsers).document(user.profile.email).setData(["email":email])
                        self.performSegue(withIdentifier: Constants.loginSegue, sender: nil)
                    }
                }else{
                    self.performSegue(withIdentifier: Constants.loginSegue, sender: nil)
                }
            }
            
        }
    }
}
