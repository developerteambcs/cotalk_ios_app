//
//  FormatString.swift
//  COTalk
//
//  Created by BCS Media on 1/12/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import Foundation

class FormatString {
    
    func giveSpaces(strChange:String)->String{
        let newstring = strChange.replacingOccurrences(of: "\\n", with: "\n", options: .regularExpression, range: nil)
        
        print(newstring)
        return newstring
    }
}
