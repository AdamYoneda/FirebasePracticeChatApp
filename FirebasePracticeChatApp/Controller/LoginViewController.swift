//
//  LoginViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak private var email: UITextField!
    @IBOutlet weak private var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func loginPressed(_ sender: UIButton) {
        guard let email = email.text else { return }
        guard let password = password.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if let e = error {
                print("Auth Login 失敗: \(e)")
            } else {
                print("Auth Login 成功")
                self?.performSegue(withIdentifier: K.SegueIdentifier.loginToChat, sender: strongSelf)
            }
        }
    }
    
    @IBAction private func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
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
