//
//  Message.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/26.
//

import Foundation
import UIKit
import Firebase

struct Message {
    
    let senderName: String
    let message: String
    let senderUid: String
    let createdAt: Timestamp
    
    init(dictionary: [String: Any]) {
        self.senderName = dictionary[K.FStore.Messages.senderName] as? String ?? ""
        self.message = dictionary[K.FStore.Messages.message] as? String ?? ""
        self.senderUid = dictionary[K.FStore.Messages.senderUid] as? String ?? ""
        self.createdAt = dictionary[K.FStore.Messages.createdAt] as? Timestamp ?? Timestamp()
    }
}
