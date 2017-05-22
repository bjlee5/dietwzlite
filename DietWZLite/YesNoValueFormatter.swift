//
//  YesNoValueFormatter.swift
//  Moblzip
//
//  Created by Sujit Maharana on 12/12/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import Foundation



class YesNoValueFormatter: NumberFormatter {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init() {
        super.init()
        self.locale = Locale.current
    }
    
//    let YesNoValues = ["No", "Yes"]
    
    override func string(from val: NSNumber) -> String? {
        
        
        switch Int(val) {
        case 0:
            return "No"
        case 1:
            return "Yes"
        default:
            return ""
        }
        
//        return YesNoValues[Int(val)]
    }
    
    static let sharedInstance = YesNoValueFormatter()
}
