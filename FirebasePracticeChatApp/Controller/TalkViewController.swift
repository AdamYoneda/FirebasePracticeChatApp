//
//  TalkViewController.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TalkViewController: UIViewController {
    
    public var sender: User?
    public var chatRoom: ChatRoom? {
        didSet {
            navigationItem.title = chatRoom?.partnerUer?.username
        }
    }
    private let db = Firestore.firestore()
    private var messages: [Message] = []
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var talkTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        talkTable.delegate = self
        talkTable.dataSource = self
        talkTable.backgroundColor = UIColor.darkGray
        talkTable.register(UINib(nibName: K.Xib.talkCell_1, bundle: nil), forCellReuseIdentifier: K.CellID.talkCell)
        // 1番下のCellの表示が途切れないようにする
        talkTable.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
        // 右のスクロールバーが見切れないように設定
        talkTable.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 40, right: 0)
        fetchMessages()
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        
    }
    
    /// Firebaseに入力したメッセージ(text)を保存していく
    @IBAction func sendMessage(_ sender: UIButton) {
        print("[T-send 1] Firestoreのコレクション'message'に保存するメッセージ（テキスト）を作成")
        // 保存する辞書型のデータを作成
        guard let chatroomDocId = chatRoom?.documentId else {
            print("chatRoomDocIdの取得に失敗")
            return
        }
        guard let senderUser = self.sender else {
            print("senderの取得に失敗")
            return
        }
        let messageData: [String: Any] = [
            K.FStore.Messages.senderName: senderUser.username,
            K.FStore.Messages.createdAt: Timestamp(),
            K.FStore.Messages.senderUid: senderUser.uid!,
            K.FStore.Messages.message: messageTextField.text!
        ]
        
        print("[T-send 2] .setDataでデータを追加する")
        // Firebaseにメッセージを保存する(.setData)
        // https://firebase.google.com/docs/firestore/manage-data/add-data?hl=ja#set_a_document
        // コレクション'chatRooms'/ドキュメント'chatRoomId(UUID)'/コレクション'messages'にデータを保存していく
        db.collection(K.FStore.collectionName_ChatRooms)
            .document(chatroomDocId).collection(K.FStore.collectionName_Messages)
            .document().setData(messageData) { error in
                if let e = error {
                    print("コレクション'messages'にmessage情報を保存することに失敗：\(e)")
                    return
                } else {
                    print("コレクション'messages'にmessage情報を保存することに成功")
                    self.messageTextField.text = ""  // 送信（Firestoreに保存）後に何も表示しない
                }
            }
    }
    
    /// 画面をタップすると、キーボードが閉じる
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /// Firestoreに保存されているメッセージをコレクション'messages'から取得する
    private func fetchMessages() {
        // chatRoomsのドキュメントIDを取得
        guard let chatroomDocId = chatRoom?.documentId else {
            print("chatRoomDocIdの取得に失敗")
            return
        }
        print("[T-fetch 1] addSnapshotLitenerでコレクション'message'から情報を取得")
        
        // addSnapshotLitenerでデータを取得する / .order()で、並べ替え
        // https://firebase.google.com/docs/firestore/query-data/order-limit-data?hl=ja#order_and_limit_data
        db.collection(K.FStore.collectionName_ChatRooms)
            .document(chatroomDocId).collection(K.FStore.collectionName_Messages).order(by: K.FStore.Messages.createdAt)
            .addSnapshotListener { querySnapthot, error in
                if let e = error {
                    print("コレクション'messages'からメッセージの情報の取得に失敗：\(e)")
                    return
                } else {
                    print("コレクション'messages'からメッセージの情報の取得に成功")
                    // 取得したQuerySnapshotから、.documentChangesで、snapshot間の変更を見ていく
                    // https://firebase.google.com/docs/firestore/query-data/listen?hl=ja#view_changes_between_snapshots
                    guard let snapshot = querySnapthot else {
                        print("Error fetching documents")
                        return
                    }
                    print("[T-fetch 2] documentChangesでsnapshot間の変更を見ていく")
                    
                    snapshot.documentChanges.forEach { diff in
                        switch diff.type {
                        case .added:
                            print("[T-fetch 3] 取得したdocumentChangeから、Messageオブジェクトを作成し、配列messagesに追加")
                            // 取得したdocumentChangeから、Messageオブジェクトを作成
                            let messageDic = diff.document.data()
                            var generatedMessage = Message(dictionary: messageDic)
                            generatedMessage.partnerUser = self.chatRoom?.partnerUer
                            self.messages.append(generatedMessage)

                            DispatchQueue.main.async {
                                self.talkTable.reloadData()
                                // 最新のメッセージCellまでスクロール
                                self.talkTable.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                            }
                            
                        case .modified, .removed:
                            print("documentChangesのtypeが.modified or .removed")
                        }
                    }
                }
            }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension TalkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        talkTable.estimatedRowHeight = 25
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let talkCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.talkCell, for: indexPath) as! TalkCell
        talkCell.message = messages[indexPath.row]
        return talkCell
    }
    
}

//MARK: - UITextFieldDelegate

extension TalkViewController: UITextFieldDelegate {
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
