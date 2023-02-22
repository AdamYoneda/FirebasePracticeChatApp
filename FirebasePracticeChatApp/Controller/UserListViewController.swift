//
//  UserListViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class UserListViewController: UIViewController {

    let db = Firestore.firestore()
    var users: [User] = []

    @IBOutlet weak var userListTableView: UITableView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        fetchInfoFromFirestore()
    }
    
    private func setUpViews() {
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        addFriendButton.layer.cornerRadius = 15
        userListTableView.register(UINib(nibName: K.Xib.userListCell, bundle: nil), forCellReuseIdentifier: K.CellID.userListCell)
        navigationItem.title = "User List"
    }
    
    // Firestoreからドキュメントを取得
    // https://firebase.google.com/docs/firestore/query-data/get-data?hl=ja#get_a_document
    private func fetchInfoFromFirestore() {
        let docRef = db.collection(K.FStore.collectionName_Users)
        docRef.getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Firestoreからのドキュメントの取得に失敗: \(e)")
                return
            } else {
                print("Firestoreからのドキュメントの取得に成功")
                guard let snapshotDoc = querySnapshot?.documents else { return }
                for doc in snapshotDoc {
                    let user = User.init(dictionary: doc.data())
                    // currentUserの情報を表示しないようにする
                    guard let uid = Auth.auth().currentUser?.uid else { return }    // ログイン中のユーザーのUUIDを取得
                    if uid != doc.documentID {  // Firestoreのドキュメント'users'に割り振られたUUIDが.documentIDに該当する
                        self.users.append(user)
                    }
        
                    DispatchQueue.main.async {
                        self.userListTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userListCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.userListCell, for: indexPath) as! UserListCell
        userListCell.user = users[indexPath.row]
        return userListCell
    }
    
    
}
