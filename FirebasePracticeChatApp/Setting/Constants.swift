
//
//  Constants.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import Foundation

struct K {
    
    struct CellID {
        static let chatCell: String = "ChatCell"
        static let talkCell: String = "TalkCell"
        static let userListCell: String = "UserListCell"
    }
    
    struct SegueIdentifier {
        static let registerToChat: String = "RegisterToChatRoom"
        static let loginToChat: String = "LoginToChatRoom"
        static let chatToTalk: String = "ChatRoomToTalk"
        static let chatListToUserList = "ChatListToUserList"
    }
    
    struct Xib {
        static let chatlistCell: String = "ChatListCell"
        static let talkCell_1 = "MessageCell_1"
        static let userListCell = "UserListCell"
    }
    
    struct FStore {
        static let collectionName_Users = "users"
        static let collectionName_ChatRooms = "chatRooms"
        static let collectionName_Messages = "messages"
        
        struct UserInfo {
            static let email = "email"
            static let username = "username"
            static let createdTime = "createdAt"
            static let iconImageURL = "iconImageURLinStorage"
        }
        
        struct ChatRooms {
            static let members = "members"
            static let latestMessageID = "latestMessageID"
            static let createdAt = "createdAt"
        }
        
        struct Messages {
            static let senderName = "senderName"
            static let createdAt = "createdAt"
            static let senderUid = "senderUid"
            static let message = "message"
        }
    }
    
    struct Storage {
        static let iconImage = "icon_image"
    }
    
}
