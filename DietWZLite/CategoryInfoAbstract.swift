//
//  CategoryInfoAbstract.swift
//  Moblzip
//
//  Created by Sujit Maharana on 4/11/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

import UIKit
import Parse

class CategoryInfoAbstract: DWBaseParse {
    
    var mode: CategoryMode {
        get {
            if self["mode"] != nil {
                return CategoryMode(rawValue: self["mode"] as! Int)!
            } else {
                return .unknown
            }
        }
        set(newValue) {
            self["mode"] = newValue.rawValue
        }
    }
    
//    @NSManaged var userName: String
    @NSManaged var label: String
    @NSManaged var limit: Float
    @NSManaged var point: Int
    @NSManaged var value: Float
//    @NSManaged var userDefined: Bool
    // TODO: Check if delete after 31 days is implemented on cloud
//    @NSManaged var deleted: Bool //If this field is true, delete this row after 31 days, during a sync operation; because the app generally stores only 31 days of storage
    
    
    var userDefined: Bool {
        get { return self["userDefined"] as! Bool }
        set { self["userDefined"] = newValue }
    }
    
    var deleted: Bool? {
        get { return self["deleted"] as? Bool }
        set { self["deleted"] = newValue }
    }
    
    override init() {
        super.init()
    }
    
    init(category: CategoryInfo) {
        super.init()
        mode = category.mode
        label = category.label
        limit = category.limit
        point = category.point
        value = 0
        userDefined = category.userDefined
        userName = Utils.sharedInstance.userInfo.username
    }
    
    init(userDefinedCategory: Bool, mode: CategoryMode?, label: InfoItem.Data?, limit: Float?, value: Float?) {
        super.init()
        self.mode = mode ?? .unknown
        self.label = label?.displayFormat ?? ""
        self.limit = limit ?? 99
        self.value = value ?? 0
        self.point = 2
        self.userDefined = userDefinedCategory
        
        userName = Utils.sharedInstance.userInfo.username
    }
    
    convenience init(userDefinedCategory: Bool) {
        self.init(userDefinedCategory: userDefinedCategory, mode: nil, label: nil)
    }
    
    convenience init(userDefinedCategory: Bool, mode: CategoryMode?, label: InfoItem.Data?) {
        self.init(userDefinedCategory: userDefinedCategory, mode: mode, label: label, limit: nil)
    }
   
    convenience init(userDefinedCategory: Bool, mode: CategoryMode?, label: InfoItem.Data?, limit: Float?) {
        self.init(userDefinedCategory: userDefinedCategory, mode: mode, label: label, limit: limit, value: nil)
    }
        
    override func remove() {
        dlog("Marking \(parseClassName) for Deletion Locally for id \(objectId)")
        self.deleted = true
        //        pinInBackgroundWithName(ParsePin.SaveToCloud.rawValue, block: nil)
        try! pin(withName: ParsePin.SaveToCloud.rawValue)
        unpinInBackground(withName: ParsePin.Local.rawValue, block: nil)
    }
    
    override func saveLocally() {
        super.saveLocally(true, idString: " \(label), value = \(value)")
    }
    
    func getCategoryPoint() -> Int {
        if mode == .counter {
            if label == InfoItem.Data.Alcohol.rawValue {
                let userInfo = Utils.sharedInstance.userInfo
                if userInfo.isMan() {
                    return Int(min(0, max(limit, 2 - value)))
                } else {
                    return Int(min(0, max(limit, 1 - value)))
                }
            }
            if limit >= 0 {
                return Int(max(0, min(limit, value)))
            } else {
                return Int(min(0, max(limit, -value)))
            }
        } else if mode == .question && value == 1 {
            return 1
        }
        
        return 0
    }
    
    func reset() {
        value = (mode == .question) ? -1 : 0
    }

    func equals(_ rhs: CategoryInfoAbstract) -> Bool {
        return self.label == rhs.label && self.mode == rhs.mode
    }
    
    func clone(_ category: CategoryInfoAbstract) {
        mode = category.mode
        label = category.label
        limit = category.limit
        point = category.point
        value = category.value
        userDefined = category.userDefined
        userName = category.userName
    }
    
    func getIndex(_ catArray: [CategoryInfoAbstract]) -> Int?{
        return catArray.index {$0.label == self.label && $0.mode == self.mode}
    }
}

func ==(lhs: CategoryInfoAbstract, rhs: CategoryInfoAbstract) -> Bool {
    return lhs.label == rhs.label && lhs.mode == rhs.mode
}
