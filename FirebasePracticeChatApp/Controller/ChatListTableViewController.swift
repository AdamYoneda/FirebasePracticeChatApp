//
//  ChatTableViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatListTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    private var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Xibファイルを使って、Cellのデザインを指定
        tableView.register(UINib(nibName: K.Xib.chatlistCell, bundle: nil), forCellReuseIdentifier: K.CellID.chatCell)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchInfoFromFirestore()
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
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    //MARK: - IBAction

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 各入力値はclass ChatListCell内で、
        let chatlistCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.chatCell, for: indexPath) as! ChatListCell
        chatlistCell.user = users[indexPath.row]
        return chatlistCell
    }
    
}

