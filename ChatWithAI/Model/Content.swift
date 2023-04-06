//
//  Content.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import Foundation

enum Name:String{
    case chatgpt = "chatgpt"
    case user = "me"
    
}

struct Content{
    let name:Name
    let text:String
}


