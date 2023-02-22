//
//  ChatListCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import Nuke

class ChatListCell: UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                latestMessage.text = user.email // 仮
                userName.text = user.username
                time.text = dateFormatterForDateLabel(date: (user.createdAt.dateValue()))
                let url = URL(string: user.iconImageURLinStorage)!
                Nuke.loadImage(with: url, into: userIconImage, completion: nil)
            }
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
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
