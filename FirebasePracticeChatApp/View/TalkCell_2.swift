//
//  TalkCell_2.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/19.
//

import UIKit

class TalkCell_2: UITableViewCell {

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
    
}
