//
//  DatabaseManager.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/17.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage


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
    let profilePictureUrl:String?
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

//final class: this class cannot be subclassed called
final class DatabaseManager{
    //singleton
    static let shared = DatabaseManager()
    //從數據庫讀取或寫入數據realtime database
    private let databaseReference:DatabaseReference =  Database.database().reference()
    //上傳檔案到storage
    private let storageReference:StorageReference = Storage.storage().reference()
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
        
        databaseReference.child("User").child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            
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
        databaseReference.child("User").child(user.safeEmail).setValue(
            [
            "first_name": user.firstName,
            "last_name": user.lastName,
            "profile":user.profilePictureUrl
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
        
        databaseReference.child("User").child(user.safeEmail).child("conversations").child("\(date)").setValue(message)

    }
    ///Insert picture to database
   public func uploadPhoto(image:UIImage?, completion:@escaping (Result<URL, Error>)-> Void)
    {
        let fileReference = storageReference.child(UUID().uuidString + ".jpg")
        if let imageData = image?.jpegData(compressionQuality: 0.7)
        {
            fileReference.putData(imageData, metadata: nil)
            { result in
                switch result
                {
                    case .success:
                    fileReference.downloadURL(completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
    }
    
    public func loadConversations(email:String, completion:@escaping (DataSnapshot)->Void){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        databaseReference.child("User").child(safeEmail).child("conversations").observeSingleEvent(of:.value)
        { snapshot in
            guard snapshot.children.allObjects as? [DataSnapshot] != nil else{
                print("no data in Firebase")
                return
            }
           completion(snapshot)
        }
    }
    public func loadProfile(email:String, completion:@escaping (DataSnapshot?)-> Void){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        databaseReference.child("User").child(safeEmail).child("profile").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.children.allObjects as? [DataSnapshot] != nil else{
                print("no data in Firebase")
                return
            }
            completion(snapshot)
        }
    }
}

