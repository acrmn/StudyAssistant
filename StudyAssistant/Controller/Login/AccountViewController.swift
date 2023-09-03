//
//  AccountViewController.swift
//  StudyAssistant
//
//  Created by Carmen Alonso on 7/8/23.
//

import UIKit

class AccountViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBAction func signOut(_ sender: UIButton) {
        defaults.set(false, forKey: Constants.loginKey)
        
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LogInViewController
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
        
        performSegue(withIdentifier: Constants.logoutSegue, sender: self)
    }
    
}
