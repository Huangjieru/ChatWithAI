//
//  FetchAPI.swift
//  ChatWithAI
//
//  Created by jr on 2023/3/5.
//

import Foundation

struct APICaller{
    static let shared = APICaller()
    private let apiKey = "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"
    private let baseURL:URL = URL(string: "https://api.openai.com/v1/")!
    
    func fetchChatGPTAPI(prompt:String,completion:@escaping(OpenAPIResponse)->Void){
        let completionsURL = APICaller.shared.baseURL.appending(component: "completions")
        var request = URLRequest(url: completionsURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(APICaller.shared.apiKey) ", forHTTPHeaderField: "Authorization")
        let openAIBody = OpenAPIParameters(prompt: prompt)
        request.httpBody = try? JSONEncoder().encode(openAIBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in

            if let data = data{
                do
                {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                    let openAPIResponse = try jsonDecoder.decode(OpenAPIResponse.self, from: data)
//                    print(openAPIResponse)
                    completion(openAPIResponse)
                }
                catch
                {
                    print(error)
                }
            }
        }.resume()
    }
}
