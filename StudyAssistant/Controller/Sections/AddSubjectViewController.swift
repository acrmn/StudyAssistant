//
//  Created by Carmen Alonso
//
// Do not use or distribute without authorization
//

import UIKit

protocol SubjectsTableDelegate {
    func didAddSubject(subjectTitle: String, subjectId: String, red: CGFloat, green: CGFloat, blue: CGFloat)
    func didEditSubject(subjectTitle: String, subjectId: String, red: CGFloat, green: CGFloat, blue: CGFloat)
}

class AddSubjectViewController: UIViewController {
    
    var subjectDelegate: SubjectsTableDelegate!

    @IBOutlet weak var subjectName: UITextField!
    @IBOutlet weak var colorPreview: UIView!
    @IBOutlet weak var pickColorButton: UIButton!
    @IBOutlet weak var colorPreviewText: UILabel!
    
    var redCompo: CGFloat?
    var greenCompo: CGFloat?
    var blueCompo: CGFloat?
    
    var editedSubjectID: String?
    
    var databaseManager = SectionsDBManager()
    
    var openedToEdit: Bool = false
    var oldTitle: String?
    var oldColor: UIColor?
    
    var saveButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        configureNavBar()
        configureButtons()
        configureColorSelection()
        
        if openedToEdit {
            self.title = Constants.editSubjectViewControllerTitle.localize()
            subjectName.text = oldTitle
            colorPreview.backgroundColor = oldColor
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }

        subjectName.addTarget(self, action: #selector(textFieldsIsNotEmpty), for: .editingChanged)
    }
    
    @objc func saveButtonAction() {

        redCompo = colorPreview.backgroundColor?.rgba.red
        greenCompo = colorPreview.backgroundColor?.rgba.green
        blueCompo = colorPreview.backgroundColor?.rgba.blue

            if let subjectID = editedSubjectID { //MARK: Edit Subject
                
                databaseManager.editSubject(r: redCompo!, g: greenCompo!, b: blueCompo!, idSubject: subjectID, titleSubject: subjectName.text!)

                subjectDelegate.didEditSubject(subjectTitle: subjectName.text!, subjectId: subjectID, red: redCompo!, green: greenCompo!, blue: blueCompo!)
                
            } else { //MARK: Add Subject

                let id = databaseManager.addSubject(r: redCompo!, g: greenCompo!, b: blueCompo!, titleSubject: subjectName.text!)
                
                subjectDelegate.didAddSubject(subjectTitle: subjectName.text!, subjectId: id, red: redCompo!, green: greenCompo!, blue: blueCompo!)
            }
            _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelButtonAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectColorAction(_ sender: Any) {
        showColorPicker()
    }
    
    func showColorPicker() {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.selectedColor = .white
        picker.supportsAlpha = false
        picker.title = Constants.colorPickerViewControllerTitle
        present(picker, animated: true, completion: nil)
    }
    
    @objc func textFieldsIsNotEmpty(sender: UITextField) {
        guard let name = subjectName!.text, !name.isEmpty
        else {
          self.saveButton.isEnabled = false
          return
        }
        saveButton.isEnabled = true
    }
    
    @objc func hideKeyboard() {
      view.endEditing(true)
    }
    
    func configureNavBar() {
        self.title = Constants.addSubjectViewControllerTitle.localize()
        navigationItem.setHidesBackButton(true, animated: false)
    }

    func configureButtons() {
        saveButton = UIBarButtonItem(title: Constants.saveButton.localize(), style: .plain, target: self, action: #selector(saveButtonAction))
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Constants.cancelButton.localize(), style: .plain, target: self, action: #selector(cancelButtonAction))
    }
    
    func configureColorSelection() {
        pickColorButton.backgroundColor = .white
        colorPreviewText.isHidden = false
        colorPreviewText.text = Constants.colorPreviewText.localize()
        pickColorButton.setTitle(Constants.colorPickButton.localize(), for: .normal)
        subjectName.placeholder = Constants.placeholderTitle.localize()
    }
}

extension AddSubjectViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        colorPreview.backgroundColor = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // Closing Color Picker
    }
}
