//
//  ChatListCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import Nuke

class ChatListCell: UITableViewCell {
    
    var chatRoom: ChatRoom? {
        didSet {
            guard let chatRoom = chatRoom else {
                print("ChatListCell.swift：ChatRoomのunwrapに失敗")
                return
            }
            latestMessage.text = chatRoom.latestMessageID
            userName.text = chatRoom.partnerUer?.username
            time.text = dateFormatterForDateLabel(date: chatRoom.createdAt.dateValue())
            let url = URL(string: chatRoom.partnerUer!.iconImageURLinStorage)!
            Nuke.loadImage(with: url, into: userIconImage, completion: nil)
        }
    }
    
    @IBOutlet weak var userIconImage: UIImageView!
    @IBOutlet weak var latestMessage: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userIconImage.layer.cornerRadius = 25
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
