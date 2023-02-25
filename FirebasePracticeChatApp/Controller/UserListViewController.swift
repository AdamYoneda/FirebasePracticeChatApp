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
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var users: [User] = []
    private var selectedUser: User?
    private let chatListVC = ChatListTableViewController()
    
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
        
        addFriendButton.isEnabled = false   // デフォルトではボタンを無効にする
        addFriendButton.layer.cornerRadius = 15
        userListTableView.register(UINib(nibName: K.Xib.userListCell, bundle: nil), forCellReuseIdentifier: K.CellID.userListCell)
        navigationItem.title = "User List"
    }
    
    // Firestoreからドキュメントを取得
    // https://firebase.google.com/docs/firestore/query-data/get-data?hl=ja#get_a_document
    private func fetchInfoFromFirestore() {
        print("[UL 1] Firestoreからログイン中のユーザー以外のユーザーの情報を取得")
        
        let docRef = db.collection(K.FStore.collectionName_Users)
        docRef.getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Firestoreからのドキュメントの取得に失敗: \(e)")
                return
            } else {
                print("Firestoreからのドキュメントの取得に成功")
                guard let snapshotDoc = querySnapshot?.documents else { return }
                for doc in snapshotDoc {
                    var user = User.init(dictionary: doc.data())
                    user.uid = doc.documentID   // 各ユーザーのuidを取得
                    
                    // currentUserの情報を表示しないようにする
                    guard let uid = self.auth.currentUser?.uid else { return }    // ログイン中のユーザーのUUIDを取得
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
    
    @IBAction func addFriendPressed(_ sender: UIButton) {
        print("[UL 2] Firestoreへチャットルームの情報を保存")
        
        // 各ユーザーのUUIDを取得
        guard let currentUserUid = auth.currentUser?.uid else { return }
        guard let partnerUid = selectedUser?.uid else { return }
        let members = [currentUserUid, partnerUid]
        
        // Firestoreに新しいCollectionを作成
        // https://firebase.google.com/docs/firestore/manage-data/add-data?hl=ja#swift
        db.collection(K.FStore.collectionName_ChatRooms).addDocument(data: [
            K.FStore.ChatRooms.members: members,
            K.FStore.ChatRooms.latestMessageID: "Latest message",
            K.FStore.ChatRooms.createdAt: Timestamp()
        ]) { error in
            if let e = error {
                print("Collection(ChatRoom)の情報の保存に失敗：\(e)")
                return
            } else {
                print("Collection(ChatRoom)の情報の保存に成功")
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource methods

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    // Cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    // 表示するCellの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    // 表示するCellの情報
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userListCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.userListCell, for: indexPath) as! UserListCell
        userListCell.user = users[indexPath.row]
        return userListCell
    }
    // 選択したCellに対する処理
    // 選択したユーザーの情報をFirestoreに保存する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser = users[indexPath.row]
        addFriendButton.isEnabled = true    // 選択後に有効にする
        
    }
    
}
