//
//  TalkCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit

class TalkCell_1: UITableViewCell {
    
    var message: Message? {
        didSet {
            if let message = message {
                messageTextView.text = message.message
                timeLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                userIcon.image = UIImage(named: "didi")
            }
        }
    }

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
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
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
