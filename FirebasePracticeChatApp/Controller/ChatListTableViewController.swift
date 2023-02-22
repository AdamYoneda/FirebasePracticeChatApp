//
//  ChatTableViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ChatListTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        fetchLoginUserInfo()
    }
    
    private func setUpViews() {
        // Xibファイルを使って、Cellのデザインを指定
        tableView.register(UINib(nibName: K.Xib.chatlistCell, bundle: nil), forCellReuseIdentifier: K.CellID.chatCell)
        rightBarButtonItem.title = "新規チャット"
        rightBarButtonItem.style = .plain
    }
    
    // ログイン中のユーザーの情報の取得
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }    // ログイン中のユーザーのUUIDを取得
        db.collection(K.FStore.collectionName_Users).document(uid).getDocument { (snapshot, err) in
            if let e = err {
                print("ログイン中のユーザーの情報の取得に失敗: \(e)")
                return
            } else {
                print("ログイン中のユーザーの情報の取得に成功")
                guard let snapshot = snapshot, let dic = snapshot.data() else { return }
                let user = User(dictionary: dic)
                self.user = user
            }
        }
    }
    
    // -------------------Firestoreから読み込む必要がなくなったため削除---------------------------------
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //
    //        fetchInfoFromFirestore()
    //    }
    //
    //    // Firestoreからドキュメントを取得
    //    // https://firebase.google.com/docs/firestore/query-data/get-data?hl=ja#get_a_document
    //    private func fetchInfoFromFirestore() {
    //        let docRef = db.collection(K.FStore.collectionName_Users)
    //        docRef.getDocuments { (querySnapshot, error) in
    //            if let e = error {
    //                print("Firestoreからのドキュメントの取得に失敗: \(e)")
    //                return
    //            } else {
    //                print("Firestoreからのドキュメントの取得に成功")
    //                guard let snapshotDoc = querySnapshot?.documents else { return }
    //                for doc in snapshotDoc {
    //                    let user = User.init(dictionary: doc.data())
    //                    // currentUserの情報を表示しないようにする
    //                    guard let uid = Auth.auth().currentUser?.uid else { return }    // ログイン中のユーザーのUUIDを取得
    //                    if uid == doc.documentID {  // Firestoreのドキュメント'users'に割り振られたUUIDが.documentIDに該当する
    //                        return
    //                    }
    //
    //                    self.users.append(user)
    //                    DispatchQueue.main.async {
    //                        self.tableView.reloadData()
    //                    }
    //                }
    //            }
    //        }
    //    }
    // -------------------Firestoreから読み込む必要がなくなったため削除---------------------------------
    
    //MARK: - IBAction
    // UerListTableVCへの画面遷移 modal
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.SegueIdentifier.chatListToUserList, sender: self)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 各入力値はclass ChatListCell内で、
        let chatlistCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.chatCell, for: indexPath) as! ChatListCell
        //        chatlistCell.user = users[indexPath.row]  //
        return chatlistCell
    }
    
}

