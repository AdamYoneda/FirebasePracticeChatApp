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
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private var logginginUser: User? {
        didSet {
            navigationItem.title = logginginUser?.username
        }
    }
    private var chatRooms: [ChatRoom] = []
    
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        rightBarButtonItem.title = "新規チャット"
        //        rightBarButtonItem.style = .plain
        
        setUpViews()
        fetchLoginUserInfo()
        fetchChatroomsInfo()
    }
    
    private func setUpViews() {
        // Xibファイルを使って、Cellのデザインを指定
        tableView.register(UINib(nibName: K.Xib.chatlistCell, bundle: nil), forCellReuseIdentifier: K.CellID.chatCell)
        
    }
    
    //MARK: - Firestoreから情報を取得
    
    // ログイン中のユーザーの情報の取得 from collection'users'
    private func fetchLoginUserInfo() {
        print("[CL 1] ログイン中のユーザーの情報の取得")
        
        // ログイン中のユーザーのUUIDを取得
        guard let currentUserUid = auth.currentUser?.uid else {
            print("currentUserのUidの取得に失敗")
            return
        }
        db.collection(K.FStore.collectionName_Users).document(currentUserUid).getDocument { (snapshot, err) in
            if let e = err {
                print("ログイン中のユーザーの情報の取得に失敗: \(e)")
                return
            } else {
                print("ログイン中のユーザーの情報の取得に成功")
                guard let snapshot = snapshot, let dic = snapshot.data() else { return }
                let user = User(dictionary: dic)
                self.logginginUser = user
            }
        }
    }
    
    // chatRoomsの情報を取得 from collection'chatRooms'
    // https://firebase.google.com/docs/firestore/query-data/listen?hl=ja
    private func fetchChatroomsInfo() {
        print("[CL 2] chatRoomsの情報を取得")
        
        db.collection(K.FStore.collectionName_ChatRooms).addSnapshotListener { querySnapshot, error in
            if let e = error {
                print("コレクション'chatRooms'の情報の取得に失敗: \(e)")
                return
            } else {
                print("コレクション'chatRooms'の情報の取得に成功")
                guard let snapshot = querySnapshot else { return }
                
                // documentChangesを使って、snapshot間の変更部分のみを追加する
                // https://firebase.google.com/docs/firestore/query-data/listen?hl=ja#view_changes_between_snapshots
                snapshot.documentChanges.forEach({ diff in
                    print("[CL 3] docmentChangesを使って、追加された情報のみを追加する")
                    
                    switch diff.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: diff)
                    case .modified, .removed:
                        print("documentChangesのtypeが.modified or .removed")
                    }
                })
                
            }
        }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        // 変更があった部分のdocument(追加されたdocument)
        let doc = documentChange.document
        // 取得したquerySnapshotからChatRoomを作成
        var chatRoom = ChatRoom(dictionary: doc.data())
        // ChatRoomのプロパティdocumentIdに、コレクション'chatRooms'から取得した.documentIDを代入する
        chatRoom.documentId = doc.documentID
        // ログイン中のユーザーのuidをAuthから取得
        guard let currentUserUid = self.auth.currentUser?.uid else { return }
        // ログイン中のユーザーが、chatRoom.membersに含まれているかを判定(含まれていなければ以下の処理を行わない)
        let currentUserisContain = chatRoom.members.contains(currentUserUid)
        if !currentUserisContain { return }  // ログイン中のユーザーを含まない場合は以下の処理を省略
        print("[CL 4] Partner Userの情報を取得")
        
        // partnerUserを作成する
        for memberUid in chatRoom.members {
            if currentUserUid != memberUid {    // uidで判定
                // Firestoreのコレクション'uers'から、partner userの情報を取得
                self.db.collection(K.FStore.collectionName_Users)
                    .document(memberUid)
                    .getDocument { documentSnapshot, error in
                        if let e = error {
                            print("コレクション'users'からpartner userの情報の取得に失敗: \(e)")
                            return
                        } else {
                            print("コレクション'users'からpartner userの情報の取得に成功")
                            guard let dictionary = documentSnapshot?.data() else { return }
                            var generatedUser = User(dictionary: dictionary)
                            generatedUser.uid = memberUid   // コレクション'users'からの情報にはuidの情報がないため、代入
                            
                            print("[CL 5] partner userプロパティに代入し、配列chatRoomsに追加していく")
                            
                            // ChatRoomのプロパティpartnerUserに、generatedUserを代入する
                            chatRoom.partnerUer = generatedUser
                            // ChatRoomの情報を変数に与える
                            self.chatRooms.append(chatRoom)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
            }
        }
    }
    
    
    //MARK: - IBAction
    
    // UerListTableVCへの画面遷移 modal
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.SegueIdentifier.chatListToUserList, sender: self)
    }
    
    // MARK: - tableViewDelegate, tableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 各入力値はclass ChatListCell内で、
        let chatlistCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.chatCell, for: indexPath) as! ChatListCell
        chatlistCell.chatRoom = chatRooms[indexPath.row]
        return chatlistCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.SegueIdentifier.chatToTalk, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.SegueIdentifier.chatToTalk {
            let talkViewController = segue.destination as! TalkViewController
            if let index = sender as? IndexPath {
                talkViewController.chatRoom = chatRooms[index.row]
                talkViewController.chatRoom?.partnerUer = chatRooms[index.row].partnerUer
                talkViewController.sender = logginginUser
                talkViewController.sender?.uid = auth.currentUser?.uid
            }
        }
    }
}

