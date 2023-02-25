//
//  ChatRoom.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/24.
//

import Foundation
import UIKit
import Firebase

struct ChatRoom {
    
    let members: [String]
    let latestMessageID: String
    let createdAt: Timestamp
    
    var partnerUer: User?
    var documentId: String?
    
    init(dictionary: [String: Any]) {
        self.members = dictionary[K.FStore.ChatRooms.members] as? [String] ?? []
        self.latestMessageID = dictionary[K.FStore.ChatRooms.latestMessageID] as? String ?? ""
        self.createdAt = dictionary[K.FStore.ChatRooms.createdAt] as? Timestamp ?? Timestamp()
    }
    
}
