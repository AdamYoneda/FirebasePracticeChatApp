//
//  RegisterViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak private var iconImage: UIImageView!
    @IBOutlet weak private var username: UITextField!
    @IBOutlet weak private var email: UITextField!
    @IBOutlet weak private var password: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        iconImage.layer.cornerRadius = 50
        
        username.delegate = self
        email.delegate = self
        password.delegate = self
        
    }
    
    @IBAction private func addImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // 画面をタップするとキーボードをフェードアウトさせる
    @IBAction private func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - Upload User Info to Firestore/Storage
    
    @IBAction private func registerPressed(_ sender: UIButton) {
        // Storageへの画像ファイルのアップロード、Authでのユーザー新規登録、Firestoreへのユーザー新規の保存
        uploadImageToStorage()
        // ChatListTableVCへの画面遷移
        self.performSegue(withIdentifier: K.SegueIdentifier.registerToChat, sender: self)
    }
    
    private func createUser(iconImageURL: String) {
        // 2. Authでユーザー登録
        // https://firebase.google.com/docs/auth/ios/start?hl=ja#sign_up_new_users
        guard let email = self.email.text else { return }
        guard let password = self.password.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let e = error {
                print("FirebaseAuth: 新規ユーザー登録に失敗：\(e)")
                return
            } else {
                print("FirebaseAuth: 新規ユーザー登録に成功")
                
                // 3. Authに新規登録したユーザーの情報をFirestoreに追加する
                // func uploadImageToStorage からdownloadURLを渡され、URLもドキュメントに保存
                // https://firebase.google.com/docs/firestore/manage-data/add-data?hl=ja#swift
                guard let uid = result?.user.uid else { return }
                guard let username = self.username.text else { return }
                
                self.db.collection(K.FStore.collectionName_Users).document(uid).setData([
                    K.FStore.UserInfo.email: email,
                    K.FStore.UserInfo.username: username,
                    K.FStore.UserInfo.createdTime: Timestamp(),
                    K.FStore.UserInfo.iconImageURL: iconImageURL
                ]) { error in
                    if let e = error {
                        print("データの追加に失敗 Error writing document：\(e)")
                        return
                    } else {
                        print("データの追加に成功 Document successfully written")
                    }
                }
            }
        }
    }
    
    private func uploadImageToStorage() {
        // 1. Firebase Storageへの画像のアップロード
        guard let image = iconImage.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }     // imageを小さくする
        
        // Referenceの作成
        // https://firebase.google.com/docs/storage/ios/create-reference?hl=ja#create_a_reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // メモリ内のデータからアップロード
        // https://firebase.google.com/docs/storage/ios/upload-files?hl=ja#upload_from_data_in_memory
        let fileName = UUID().uuidString
        // アップロードしたいファイルのReferenceの作成
        let imageRef = storageRef.child(K.Storage.iconImage).child(fileName)
        let uploadTask = imageRef.putData(uploadImage, metadata: nil) { metadata, error in
            if let e = error {
                print("Storageへの画像のアップロードに失敗: \(e)")
                return
            } else {
                print("Storageへの画像のアップロードに成功")
                
                // metadataからDownload URLを取得し、Firestoreに保存する
                guard let metadata = metadata else { return }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL: String = url?.absoluteString else { return }
                    self.createUser(iconImageURL: downloadURL)
                }
            }
        }
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
