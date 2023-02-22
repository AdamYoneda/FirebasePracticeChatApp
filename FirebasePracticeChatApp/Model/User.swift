//
//  User.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/21.
//

import UIKit
import Firebase
import Nuke

struct User {
    
    let username: String
    let email: String
    let createdAt: Timestamp
    let iconImageURLinStorage: String
    
//    var generatedImage: UIImage
    
//    var image: UIImage? {
//        do {
//            let url = URL(string: iconImageURLinStorage)
//            let data = try Data(contentsOf: url!)
//            let generatedImage = UIImage(data: data)
//        } catch {
//            print("DLしたURLから画像の生成に失敗")
//            return nil
//        }
//    }
//        get {
//            var generatedImage: UIImage? = nil
//            if let url = URL(string: iconImageURLinStorage) {
//                URLSession.shared.dataTask(with: url) { data, response, error in
//                    if let e = error {
//                        print("画像のDLに失敗：\(e)")
//                        return
//                    }
//                    if let data = data, let image = UIImage(data: data) {
//                        generatedImage = image
//                    } else {print("DLしたデータからの画像の作成に失敗")}
//                }
//                return generatedImage
//            } else {
//                print("aaa")
//                return nil
//            }
//        }
//    }
    
    init(dictionary: [String: Any]) {
        self.username = dictionary[K.FStore.UserInfo.username] as? String ?? ""
        self.email = dictionary[K.FStore.UserInfo.email] as? String ?? ""
        self.createdAt = dictionary[K.FStore.UserInfo.createdTime] as? Timestamp ?? Timestamp()
        self.iconImageURLinStorage = dictionary[K.FStore.UserInfo.iconImageURL] as? String ?? ""
    }
    
}
