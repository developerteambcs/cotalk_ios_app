//
//  TextFormatter.swift
//  COTalk
//
//  Created by BCS Media on 2/12/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import Foundation
import UIKit

class TextFormatter {
    
    func formatText (alltext:String)->NSAttributedString{
        var finalString = NSMutableAttributedString()
        var textcame = alltext
        var head = ""
        var body = ""
        var stringtoBeRemoved = ""
        var didLookforHeadline = false
        
        
        while textcame != "" {
            if didLookforHeadline == false{
                let currentline = textcame.components(separatedBy: "<headline>")
                if currentline.count > 0{
                    
                    let currentLineEnd = currentline[1].components(separatedBy: "</headline>")
                    head = currentLineEnd[0]
                    let font = UIFont(name: "ProximaNova-Bold", size: 17)
                    let attributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.4980392157, blue: 0.07058823529, alpha: 1)] as [NSAttributedString.Key : Any]
                    finalString.append(NSAttributedString(string: head, attributes: attributes))//appending(NSAttributedString(string: head, attributes: attributes))
                    stringtoBeRemoved = "<headline>\(head)</headline>"
                    textcame = textcame.replacingOccurrences(of: "\(stringtoBeRemoved)", with: "")
                    didLookforHeadline = true
                    
                    
                    
                    
                }
            }else{
                didLookforHeadline = false
                let currentline = textcame.components(separatedBy: "<body>")
                if currentline.count > 0{
                    let currentLineEnd = currentline[1].components(separatedBy: "</body>")
                    body = currentLineEnd[0]
                    let font = UIFont(name: "ProximaNova-Regular", size: 15)
                    let attributes = [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)] as [NSAttributedString.Key : Any]
                    finalString.append(NSAttributedString(string: body, attributes: attributes))
                    stringtoBeRemoved = "<body>\(body)</body>"
                    textcame = textcame.replacingOccurrences(of: "\(stringtoBeRemoved)", with: "")
                }
            }
            
            
            /**/
            
            /*if textcame.contains("<headline>"){
                let currentline = textcame.components(separatedBy: "<headline>")
                if currentline.count > 0{
                    let currentLineEnd = currentline[1].components(separatedBy: "</headline>")
                    head = currentLineEnd[0]
                    stringtoBeRemoved = "<headline>\(head)</headline>"
                    textcame = textcame.replacingOccurrences(of: "\(stringtoBeRemoved)", with: "")
                    didLookforHeadline = true
                }
            }else if alltext.contains("<caption>"){
                
            }else{
                let currentline = textcame.components(separatedBy: "<body>")
                if currentline.count > 0{
                    let currentLineEnd = currentline[1].components(separatedBy: "</body>")
                    body = currentLineEnd[0]
                    stringtoBeRemoved = "<body>\(body)</body>"
                    textcame = textcame.replacingOccurrences(of: "\(stringtoBeRemoved)", with: "")
                }
            }*/
        }
        
        print(head)
        print(textcame)
        return finalString
    }
    
}
