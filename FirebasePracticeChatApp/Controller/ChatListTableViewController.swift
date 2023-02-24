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
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        guard let currentUserUid = auth.currentUser?.uid else { return }    // ログイン中のユーザーのUUIDを取得
        db.collection(K.FStore.collectionName_Users).document(currentUserUid).getDocument { (snapshot, err) in
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
    
    // chatRoomsの情報を取得 from collection'chatRooms'
    private func fetchChatroomsInfo() {
        print("[CL 2] chatRoomsの情報を取得")
        
        db.collection(K.FStore.collectionName_ChatRooms).getDocuments { querySnapshot, error in
            if let e = error {
                print("コレクション'chatRooms'の情報の取得に失敗: \(e)")
                return
            } else {
                print("コレクション'chatRooms'の情報の取得に成功")
                guard let snapshotDocs = querySnapshot?.documents else { return }    // [QueryDocumentSnapshot]
                
                // 各ドキュメントからChatRoomを生成し、partner userを特定して、作成したChatRoomのプロパティに追加し、配列chatRoomsに加える
                for doc in snapshotDocs {
                    // 取得したquerySnapshotからChatRoomを作成
                    var chatRoom = ChatRoom(dictionary: doc.data())
                    // ログイン中のユーザーのuidをAuthから取得
                    guard let currentUserUid = self.auth.currentUser?.uid else { return }
                    
                    // partnerUserを作成する
                    for memberUid in chatRoom.members {
                        if currentUserUid != memberUid {    // uidで判別
                            print("[CL3] Partner Userの情報を取得")
                            
                            self.db.collection(K.FStore.collectionName_Users).document(memberUid).getDocument { documentSnapshot, error in
                                if let e = error {
                                    print("コレクション'users'からpartner userの情報の取得に失敗: \(e)")
                                    return
                                } else {
                                    print("コレクション'users'からpartner userの情報の取得に成功")
                                    guard let dictionary = documentSnapshot?.data() else { return }
                                    var generatedUser = User(dictionary: dictionary)
                                    generatedUser.uid = memberUid   // コレクション'users'にはuidの情報がないため、代入
                                    
                                    print("[CL 4] partner userプロパティに代入し、配列chatRoomsに追加していく")
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
            }
        }
    }
    
    
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
        return chatRooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 各入力値はclass ChatListCell内で、
        let chatlistCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.chatCell, for: indexPath) as! ChatListCell
        chatlistCell.chatRoom = chatRooms[indexPath.row]
        return chatlistCell
    }
    
}

