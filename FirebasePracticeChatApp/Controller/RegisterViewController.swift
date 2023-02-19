//
//  RegisterViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var username: UITextField!
    @IBOutlet weak private var email: UITextField!
    @IBOutlet weak private var password: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        iconImage.layer.cornerRadius = 50
        
        username.delegate = self
        email.delegate = self
        password.delegate = self
        
    }
    
    @IBAction private func registerPressed(_ sender: UIButton) {
        
    }
    
    @IBAction private func addImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            iconImage.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            iconImage.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            return false
        }
    }
}
