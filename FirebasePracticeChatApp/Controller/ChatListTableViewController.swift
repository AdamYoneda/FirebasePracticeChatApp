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
        
        setUpViews()
        fetchLoginUserInfo()
        fetchChatroomsInfo()
    }
    
    /// Xibファイルを使って、ChatListのCellのデザインを指定
    private func setUpViews() {
        tableView.register(UINib(nibName: K.Xib.chatlistCell, bundle: nil), forCellReuseIdentifier: K.CellID.chatCell)
        
    }
    
    //MARK: - Firestoreから情報を取得
    
    /// ログイン中のユーザーの情報の取得 from collection'users'
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
    
    /// chatRoomsの情報を取得 from collection'chatRooms'
    /// https://firebase.google.com/docs/firestore/query-data/listen?hl=ja
    private func fetchChatroomsInfo() {
        print("[CL 2] chatRoomsの情報を取得")
        
        db.collection(K.FStore.collectionName_ChatRooms).addSnapshotListener { querySnapshot, error in
            if let e = error {
                print("コレクション'chatRooms'の情報の取得に失敗: \(e)")
                return
            } else {
                print("コレクション'chatRooms'の情報の取得に成功")
                guard let snapshot = querySnapshot else { return }
                
                print("[CL 3] docmentChangesを使って、追加された情報のみを追加する")
                // documentChangesを使って、snapshot間の変更部分のみを追加する
                // https://firebase.google.com/docs/firestore/query-data/listen?hl=ja#view_changes_between_snapshots
                snapshot.documentChanges.forEach({ diff in
                    switch diff.type {
                    case .added:
                        print("documentChangeのtypeがadded")
                        self.handleAddedDocumentChange(documentChange: diff)
                    case .modified:
                        print("documentChangeのtypeがmodified")
                        self.handleModifiedDocumentChange(documentChange: diff)
                    case .removed:
                        print("documentChangesのtypeがremoved")
                    }
                })
                
            }
        }
    }
    
    /// documentChangesが.addedのときに行う処理（最終的にchatRoomsの要素を追加する）
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        // 変更があった部分のdocument(追加されたdocument)
        let doc = documentChange.document
        // 取得したquerySnapshotからChatRoomを作成
        var fetchedChatRoom = ChatRoom(dictionary: doc.data())
        // ChatRoomのプロパティdocumentIdに、コレクション'chatRooms'から取得した.documentIDを代入する
        fetchedChatRoom.documentId = doc.documentID
        // ログイン中のユーザーのuidをAuthから取得
        guard let currentUserUid = self.auth.currentUser?.uid else { return }
        // ログイン中のユーザーが、chatRoom.membersに含まれているかを判定(含まれていなければ以下の処理を行わない)
        let currentUserisContain = fetchedChatRoom.members.contains(currentUserUid)
        if !currentUserisContain { return }  // ログイン中のユーザーを含まない場合は以下の処理を省略
        print("[CL 4] Partner Userの情報を取得")
        
        // partnerUserを作成する
        for memberUid in fetchedChatRoom.members {
            if currentUserUid != memberUid {    // uidで判定
                // Firestoreのコレクション'uers'から、partner userの情報を取得
                self.db.collection(K.FStore.collectionName_Users)
                    .document(memberUid)
                    .getDocument { userSnapshot, error in
                        if let e = error {
                            print("コレクション'users'からpartner userの情報の取得に失敗: \(e)")
                            return
                        } else {
                            print("コレクション'users'からpartner userの情報の取得に成功")
                            print("[CL 5] ChatRoomのプロパティpartnerUserに値を与える")
                            
                            guard let dictionary = userSnapshot?.data() else { return }
                            var fetchedUser = User(dictionary: dictionary)
                            fetchedUser.uid = memberUid   // コレクション'users'からの情報にはuidの情報がないため、代入
                            // ChatRoomのプロパティpartnerUserに、generatedUserを代入する
                            fetchedChatRoom.partnerUer = fetchedUser
                            
                            print("[CL 6] ChatRoomのlatestMessageIDから、最新のMessageを取得")
                            guard let chatroomID = fetchedChatRoom.documentId else { return }
                            let latestMessageID = fetchedChatRoom.latestMessageID
                            
                            self.db.collection(K.FStore.collectionName_ChatRooms).document(chatroomID)
                                .collection(K.FStore.collectionName_Messages).document(latestMessageID).getDocument { messageSnapshot, error in
                                    if let e = error {
                                        print("最新のメッセージの取得に失敗:\(e)")
                                        return
                                    } else {
                                        if let dic = messageSnapshot?.data() {
                                            print("最新のメッセージの取得に成功")
                                            let fetchedMessage = Message(dictionary: dic)
                                            fetchedChatRoom.latestMessage = fetchedMessage
                                            print("[CL 7] ChatRoomのプロパティlatestMessageに値を代入し、配列chatRoomsに追加していく")
                                            self.chatRooms.append(fetchedChatRoom)
                                        } else {
                                            print("messageSnapshotの取得に失敗")
                                            self.chatRooms.append(fetchedChatRoom)  // プロパティlatestMessage: Message?がなくてもとりあえず追加
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                        }
                    }
            }
        }
    }
    
    /// documentChangeが.modifiedのときに行う処理（最終的にchatRoomsの要素を置き換える）
    private func handleModifiedDocumentChange(documentChange: DocumentChange) {
        // 変更があった部分のdocument(追加されたdocument)
        let doc = documentChange.document
        // 取得したquerySnapshotからChatRoomを作成
        var fetchedChatRoom = ChatRoom(dictionary: doc.data())
        // ChatRoomのプロパティdocumentIdに、コレクション'chatRooms'から取得した.documentIDを代入する
        fetchedChatRoom.documentId = doc.documentID
        // ログイン中のユーザーのuidをAuthから取得
        guard let currentUserUid = self.auth.currentUser?.uid else { return }
        // ログイン中のユーザーが、chatRoom.membersに含まれているかを判定(含まれていなければ以下の処理を行わない)
        let currentUserisContain = fetchedChatRoom.members.contains(currentUserUid)
        if !currentUserisContain { return }  // ログイン中のユーザーを含まない場合は以下の処理を省略
        
        // partnerUserを作成する
        for memberUid in fetchedChatRoom.members {
            if currentUserUid != memberUid {    // uidで判定
                // Firestoreのコレクション'uers'から、partner userの情報を取得
                self.db.collection(K.FStore.collectionName_Users)
                    .document(memberUid)
                    .getDocument { userSnapshot, error in
                        if let e = error {
                            print("コレクション'users'からpartner userの情報の取得に失敗: \(e)")
                            return
                        } else {
                            print("コレクション'users'からpartner userの情報の取得に成功")
                            guard let dictionary = userSnapshot?.data() else { return }
                            var generatedUser = User(dictionary: dictionary)
                            generatedUser.uid = memberUid   // コレクション'users'からの情報にはuidの情報がないため、代入
                            // ChatRoomのプロパティpartnerUserに、generatedUserを代入する
                            fetchedChatRoom.partnerUer = generatedUser
                            
                            // 以下がhandleAddedDocumentChangeとの違い
                            guard let chatroomID = fetchedChatRoom.documentId else { return }
                            let latestMessageID = fetchedChatRoom.latestMessageID
                            
                            print("[CL - modified] latestMessageIDを使って、getDocumentで最新のメッセージの情報を取得する")
                            self.db.collection(K.FStore.collectionName_ChatRooms).document(chatroomID)
                                .collection(K.FStore.collectionName_Messages).document(latestMessageID).getDocument { messageSnapshot, error in
                                    if let e = error {
                                        print("最新のメッセージの取得に失敗:\(e)")
                                        return
                                    } else {
                                        print("最新のメッセージの取得に成功")
                                        guard let documet = messageSnapshot?.data() else { return }
                                        let fetchedMessage = Message(dictionary: documet)
                                        fetchedChatRoom.latestMessage = fetchedMessage
                                        // ----------- .addedとの違い -------------
                                        // 配列chatRooms内で、fetchedChatRoomのdocumentIdと一致する要素のindexを探す
                                        // 一致する場合は、新しく作成したChatRoomオブジェクトに置き換える
                                        if let index = self.chatRooms.firstIndex(where: { $0.documentId == fetchedChatRoom.documentId}) {
                                            self.chatRooms[index] = fetchedChatRoom
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                        }
                    }
            }
        }
    }
    
    
    //MARK: - IBAction
    
    /// UerListTableVCへの画面遷移 modal
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
    // ChatListVC → TalkVCへの画面遷移
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.SegueIdentifier.chatToTalk, sender: indexPath)
    }
    
    // ChatListVC → TalkVCへの画面遷移の際に、プロパティに値を渡す
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

