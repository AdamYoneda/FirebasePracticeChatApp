//
//  UserListCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/22.
//

import UIKit
import Nuke

class UserListCell: UITableViewCell {
    
    var user: User? {
        didSet {
            if let user = user {
                userName.text = user.username
                
                let url = URL(string: user.iconImageURLinStorage)!
                Nuke.loadImage(with: url, into: userIcon, completion: nil)
            }
        }
    }
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userIcon.layer.cornerRadius = 25
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
