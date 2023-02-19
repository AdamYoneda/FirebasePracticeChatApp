//
//  AppDelegate.swift
//  FirebasePracticeChatApp
//
//  Created by Adam Yoneda on 2023/02/18.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ----------- Firebaseの初期設定 --------------
        // Cloud Firestore・Cloud Storageの初期化
        FirebaseApp.configure()
        let db = Firestore.firestore()
        // デフォルトのFirebaseAppを仕様してStorageサービスへの参照を取得
        let storage = Storage.storage()
        // StorageサービスからStorageReferenceを作成
        let storageRef = storage.reference()
        
        // ----------- NavigationBarの設定 --------------
        let newNavBarAppearance = customNavBarAppearance()
        
        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
        if #available(iOS 15.0, *) {
            appearance.compactScrollEdgeAppearance = newNavBarAppearance
        }
        appearance.tintColor = UIColor.white
        
        // ------------ UITextFieldの設定 ----------------
        let textField = UITextField()
        textField.autocapitalizationType = .words
        textField.returnKeyType = .go
        
        return true
    }
    //MARK: - Configure NavBarAppearance

    @available(iOS 13.0, *)
    func customNavBarAppearance() -> UINavigationBarAppearance {
        let customNavBarAppearance = UINavigationBarAppearance()
        
        // Background Color
        customNavBarAppearance.configureWithOpaqueBackground()
        customNavBarAppearance.backgroundColor = UIColor.gray
        
        // Apply "BLACK" colored normal and large titles.
        customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        customNavBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Apply Black color to all the nav bar buttons.
        let barButtonItemAppearance = UIBarButtonItemAppearance(style: .plain)
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        barButtonItemAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.lightText]
        barButtonItemAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.label]
        barButtonItemAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.black]
        customNavBarAppearance.buttonAppearance = barButtonItemAppearance
        customNavBarAppearance.backButtonAppearance = barButtonItemAppearance
        customNavBarAppearance.doneButtonAppearance = barButtonItemAppearance
        
        return customNavBarAppearance
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
/*
 
 <Reference to Storage>
 
// Points to the root reference
let storageRef = Storage.storage().reference()

// Points to "images"
let imagesRef = storageRef.child("images")

// Points to "images/space.jpg"
// Note that you can use variables to create child values
let fileName = "space.jpg"
let spaceRef = imagesRef.child(fileName)

// File path is "images/space.jpg"
let path = spaceRef.fullPath

// File name is "space.jpg"
let name = spaceRef.name

// Points to "images"
let images = spaceRef.parent()
 
 <Create a Reference>
 
 // Create a root reference
 let storageRef = storage.reference()

 // Create a reference to "mountains.jpg"
 let mountainsRef = storageRef.child("mountains.jpg")

 // Create a reference to 'images/mountains.jpg'
 let mountainImagesRef = storageRef.child("images/mountains.jpg")

 // While the file names are the same, the references point to different files
 mountainsRef.name == mountainImagesRef.name            // true
 mountainsRef.fullPath == mountainImagesRef.fullPath    // false
     
    
*/
