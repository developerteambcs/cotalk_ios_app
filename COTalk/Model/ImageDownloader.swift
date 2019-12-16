//
//  ImageDownloader.swift
//  COTalk
//
//  Created by BCS Media on 1/24/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//


import Foundation
import UIKit


public class ImageDownloader{
    
    var imageURL = ""
    
    
    func getBImage(imageId: String, completion: @escaping ((_ image: UIImage?) -> Void)) {
        if imageURL != ""{
            if  let imgURL = URL(string: imageURL){
                
                var request: URLRequest = URLRequest(url: imgURL)
                request.cachePolicy = .reloadIgnoringLocalCacheData
                let session = URLSession.shared
                let task = session.dataTask(with: request){
                    (data, response, error) -> Void in
                    
                    if (error == nil && data != nil){
                        completion(UIImage(data: data!))
                        
                    }
                }
                task.resume()
                
            }
            
        }
    }
    
    
}

