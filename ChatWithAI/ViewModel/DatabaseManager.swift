//
//  DatabaseManager.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/17.
//

import Foundation
import FirebaseDatabase

//final class: this class cannot be subclassed called
final class DatabaseManager{
    //singleton
    static let shared = DatabaseManager()
    //從數據庫讀取或寫入數據
    private let ref:DatabaseReference =  Database.database().reference()
    //使用setValue添加到database(json格式)
//    public func test(){
//        database.child("foo").setValue(["something":true])
//    }
    
}
//MARK: - Account Management
extension DatabaseManager{
    //if the user email not exist
    public  func userExists(with email: String,
                            completion: @escaping ((Bool)->Void))
    {
        //not contain '.' '#' '$' '[' or ']'
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        ref.child("User").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
            guard snapshot.value as? String != nil else {
              completion(false)
                return
            }
            completion (true)
        }
    }
    
    ///Inserts new user to database
    public func insertUser(with user:ChatAppUser)
    {
        ref.child("User").child(user.safeEmail).setValue(
            [
            "first_name": user.firstName,
            "last_name": user.lastName
            ]
        )
    }
    ///Insert conversations to database
    public func insertContent(with user:Message)
    {
        let message:[String:Any] =
        [
                "userMessage": user.userMessage,
                "chatgptMessage":user.chatgptMessage
        ]

        let date = Date()
        
        ref.child("User").child(user.safeEmail).child("conversations").child("\(date)").setValue(message)

    }
   
    ///get user information form database
    public func fetchUserInfo(with email:String,
                              completion: @escaping (NSDictionary)->Void)
    {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        ref.child("User").child(safeEmail).observeSingleEvent(of:.value){ snapshot in
            if let userInfoDic = snapshot.value as? NSDictionary{
                completion(userInfoDic)
            }
        }
    }
    /*
    ///get conversations form database
    public func loadConversations(with email:String,
                              completion: @escaping (String)->Void)
    {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        ref.child("User").child(safeEmail).child("conversations").observeSingleEvent(of:.value)
        { snapshot in
            if let allSnapshot = snapshot.children.allObjects as? [DataSnapshot]
            {
                for message in allSnapshot{
                    if let content = message.value as? String{
                        completion(content)
                    }
                }
                
                
            }
            
        }
    }*/
}

struct ChatAppUser{
    let firstName:String
    let lastName:String
    let emailAddress:String

    //computed property
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
//    let profilePictureUrl:String
}

struct Message{
    let account:String
    let userMessage:String
    let chatgptMessage:String
    //computed property
    var safeEmail:String{
        var safeEmail = account.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
