//
//  User.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/21.
//

import Foundation
import Firebase

struct User {
    
    let username: String
    let email: String
    let createdAt: Timestamp
    let iconImageURLinStorage: String
    
    init(dictionary: [String: Any]) {
        self.username = dictionary[K.FStore.UserInfo.username] as? String ?? ""
        self.email = dictionary[K.FStore.UserInfo.email] as? String ?? ""
        self.createdAt = dictionary[K.FStore.UserInfo.createdTime] as? Timestamp ?? Timestamp()
        self.iconImageURLinStorage = dictionary[K.FStore.UserInfo.iconImageURL] as? String ?? ""
    }
    
}
