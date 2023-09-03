//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol ProfessorsImageDelegate {
    func didChangeProfessorImage(imageName: String)
}

class ProfileSelectorViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var collection: UICollectionView!
    var selectedImageName: String?
    var originalImageName: String?
    
    let pfps = [Constants.profileImage1, Constants.profileImage2, Constants.profileImage3,
                Constants.profileImage4, Constants.profileImage5, Constants.profileImage6,
                Constants.profileImage7, Constants.profileImage8, Constants.profileImage9]
    
    var imageDelegate: ProfessorsImageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: View Configuration
        configureButtons()
        configureCollectionView()

    }
    
    @objc func saveButtonAction() {
        imageDelegate.didChangeProfessorImage(imageName: (selectedImageName ?? originalImageName) ?? Constants.profileImageDefault)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureButtons() {
        let cancelButton: UIBarButtonItem = UIBarButtonItem(title: Constants.cancelButton.localize(), style: .plain, target: self, action: #selector(cancelButtonAction))
        cancelButton.tintColor = .white
        let saveButton: UIBarButtonItem = UIBarButtonItem(title: Constants.okButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        saveButton.tintColor = .white
        
        let navigItem: UINavigationItem = UINavigationItem(title: Constants.profileSelectorViewControllerTitle.localize())
        navigItem.rightBarButtonItem = saveButton
        navigItem.leftBarButtonItem = cancelButton
        navigationBar.items = [navigItem]
        navigationBar.barTintColor = Constants.primaryBlue
        navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
    }
    
    func configureCollectionView() {
        let itemSize = UIScreen.main.bounds.width/3 - 35
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 15
        collection.collectionViewLayout = layout
    }
    
}

// MARK: - Collection Delegates
extension ProfileSelectorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pfps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.pfpCollectionViewCellId, for: indexPath) as! PfpCollectionViewCell
        cell.profileImageView.image = UIImage(named: pfps[indexPath.row])
        cell.layer.borderWidth = 0.8
        cell.layer.borderColor = Constants.cultured?.cgColor
        cell.layer.cornerRadius = cell.frame.height / 2
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageName = pfps[indexPath.row]
    }
    
}
