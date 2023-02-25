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
    
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var talkTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        talkTable.delegate = self
        talkTable.dataSource = self
        talkTable.register(UINib(nibName: K.Xib.talkCell_1, bundle: nil), forCellReuseIdentifier: K.CellID.talkCell)
        fetchMessages()
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        
    }
    
    // Firebaseに入力したメッセージを保存していく
    @IBAction func sendMessage(_ sender: UIButton) {
        
        // chatRoomsのドキュメントIDを取得
        guard let chatroomDocId = chatRoom?.documentId else {
            print("chatRoomDocIdの取得に失敗")
            return
        }
        // 保存する辞書型のデータを作成
        guard let senderUser = self.sender else {
            print("senderの取得に失敗")
            return
        }
        
        let messageData: [String: Any] = [
            K.FStore.Messages.senderName: senderUser.username,
            K.FStore.Messages.createdAt: Timestamp(),
            K.FStore.Messages.senderUid: senderUser.uid!,
            K.FStore.Messages.message: message.text!
        ]
        
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
                    self.message.text = ""  // 送信（Firestoreに保存）後に何も表示しない
                    
                }
            }
        
    }
    
    // 画面をタップすると、キーボードが閉じる
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // すでにFirestoreに保存されているメッセージを取得する
    private func fetchMessages() {
        
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension TalkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        talkTable.estimatedRowHeight = 40
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let talkCell = tableView.dequeueReusableCell(withIdentifier: K.CellID.talkCell, for: indexPath)
        //        talkCell.textLabel?.text =
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
