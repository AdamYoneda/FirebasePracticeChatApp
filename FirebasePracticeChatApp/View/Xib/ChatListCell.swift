//
//  ChatListCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit

class ChatListCell: UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                //            userIconImage.image =
                latestMessage.text = user.email // 仮
                userName.text = user.username
                time.text = dateFormatterForDateLabel(date: (user.createdAt.dateValue()))
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
