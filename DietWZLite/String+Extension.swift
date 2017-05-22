//
//  String+Extension.swift
//  Moblzip
//
//  Created by TheTerminator on 6/21/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation

extension String {
    
    mutating func replace(_ string: String, replacement: String) {
        self = self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    mutating func removeWhitespace() {
        self.replace(" ", replacement: "")
    }
    
    mutating func removeCharactersInSet(_ characters: String) {
        characters.characters.forEach{ self.replace(String($0), replacement: "") }
    }
    
//    var md5: String! {
//        
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>(allocatingCapacity: digestLen)
//
//        
//        CC_MD5(str!, strLen, result)
//        
//        let hash = NSMutableString()
//        for i in 0..<digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        
//        result.deinitialize()
//        
//        return String(format: hash as String)
//    }
}
