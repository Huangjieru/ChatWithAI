//
//  Content.swift
//  ChatWithAI
//
//  Created by jr on 2023/2/27.
//

import Foundation

enum Name:String{
    case chapgpt = "ChatGPT"
    case user = "Me"
}

struct Content{
    let name:Name
    let text:String
}

//MARK: - OpenAPI
struct OpenAPIParameters:Encodable{
    let model:String = "text-davinci-003"
    let prompt:String
    let temperature:Double = 0.8
    let max_tokens = 4000

}
struct OpenAPIResponse:Codable{
    let choices:[Choices]
}
struct Choices:Codable{
    let text:String
}
