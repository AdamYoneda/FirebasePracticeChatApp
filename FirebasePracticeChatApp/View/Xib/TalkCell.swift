//
//  TalkCell.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import FirebaseAuth
import Nuke

class TalkCell: UITableViewCell {
    
    public var message: Message?
    
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var partnerMessageTextView: UITextView!
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var partnerTimeLabel: UILabel!
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var partnerMessageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        checkWhichUserMessage()
    }
    
    // メッセージの送信者を判定
    private func checkWhichUserMessage() {
        guard let myUid = Auth.auth().currentUser?.uid else { return }
        if myUid == message?.senderUid {
            // このときはcurrentUserのメッセージ
            partnerMessageTextView.isHidden = true
            partnerTimeLabel.isHidden = true
            userIcon.isHidden = true
            myMessageTextView.isHidden = false
            myTimeLabel.isHidden = false
            
            if let message = message {
                myMessageTextView.text = message.message
                myTimeLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                let width = estimateFrameForTextView(text: message.message).width + 20
                myMessageWidthConstraint.constant = width
            }
        } else {
            // このときはpartnerUserのメッセージ
            partnerMessageTextView.isHidden = false
            partnerTimeLabel.isHidden = false
            userIcon.isHidden = false
            myMessageTextView.isHidden = true
            myTimeLabel.isHidden = true
            
            if let message = message {
                partnerMessageTextView.text = message.message
                partnerTimeLabel.text = dateFormatterForDateLabel(date: message.createdAt.dateValue())
                let url = URL(string: message.partnerUser!.iconImageURLinStorage)!
                Nuke.loadImage(with: url, into: userIcon, completion: nil)
                let width = estimateFrameForTextView(text: message.message).width + 20
                partnerMessageWidthConstraint.constant = width
            }
        }
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // Cellのwidthを調節する
    private func estimateFrameForTextView(text: String) -> CGRect {
        // 最大値を設定
        let size = CGSize(width: 200, height: 1000)
        // よく分からない
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size,options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
}
