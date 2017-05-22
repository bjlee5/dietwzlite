//
//  ChoiceValueFormatter.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 12/12/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import Foundation

class ChoiceValueFormatter: NumberFormatter {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init() {
        super.init()
        self.locale = Locale.current
    }
    
    override func string(from choiceValue: NSNumber) -> String {
        if Int(choiceValue) < -2 {
            return ""
        }
        return MealWeight(rawValue: Int(choiceValue))?.stringValue ?? ""
    }
    
    static let sharedInstance = ChoiceValueFormatter()
}
