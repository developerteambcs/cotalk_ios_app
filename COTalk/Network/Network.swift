//
//  Network.swift
//  COTalk
//
//  Created by BCS Media on 1/5/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import Foundation

public class Network{
    
    func NetworkRequest(url:String,body:String,completion: @escaping (_ dictionary: Any, _ error: Error?) -> Void){
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        print(body)
        request.httpBody = body.data(using: String.Encoding.utf8)
        request.allHTTPHeaderFields = ["Content-Type": "json"]
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                
                print("error=\(String(describing: error))")
                completion([:], error)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                
                
            }else{
                UserDefaults.standard.set(true, forKey: "AlreadySigned")
                do {
                    
                    if let json = try? JSONSerialization.jsonObject(with: data, options: [])//try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any]
                        
                    {
                        
                        
                        print(json)
                        
                        
                        
                        
                        completion(json, nil)
                        
                        
                        
                    }
                    
                } catch {
                    
                    print(error.localizedDescription)
                    completion([:], error)
                }
            }
            
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            print("response = \(String(describing: response))")
            
        }
        task.resume()
        
    }
    
}

