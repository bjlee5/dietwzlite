//
//  DWBaseParse.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 3/15/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

/// This is a base DietWz base parse Domain Object class, that has the logic for saving to local and cloud as well as tracking any DB operations
class DWBaseParse: PFObject  { //, Equatable {
    
    
    @NSManaged var userName: String
    
//    var userName: String {
//        get {
//            if self["userName"] == nil {
//                return ""
//            } else {
//                return self["userName"] as! String
//            }
//        }
//        set(newValue) {
//            dlog("Trying to set userName \(newValue)  -  \(parseClassName)")
////            if let n = newValue {
////                dlog("Going Here")
////                self["userName"] = n
////            } else {
////                dlog("Going there")
////                self["userName"] = ""
////            }
////            self["userName"] = newValue!.isEmpty ? "" : newValue
//            
////            if newValue!.isEmpty {
//            if newValue.isEmpty {
//                dlog("Going Here")
//                self["userName"] = "_NoUser_"
//            } else {
//                dlog("Going there")
//                self["userName"] = newValue
//            }
//            dlog("Successfully set user name")
//
//        }
//    }
    
//    let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
    
    override init() {
        super.init()
//        userName = Utils.sharedInstance.userInfo.username
    }
    
//    override class func initialize() {
//        superclass()?.load()
//        self.registerSubclass()
//    }
//    
//    class func parseClassName() -> String {
//        return ParseClassName.DWBaseParse.rawValue
//    }
    
    
    /// This method saves this record locally and is tagged that a save operation has happened
    func saveLocally() {
        dlog("Saving \(parseClassName) Locally for id \(objectId)")
//        pinInBackgroundWithName(ParsePin.Local.rawValue, block: nil)
        try! pin(withName: ParsePin.Local.rawValue)
    }
    
    func remove() {
        dlog("Removing \(parseClassName) Locally for id \(objectId)")
        unpinInBackground(withName: ParsePin.Local.rawValue, block: nil)
    }

    
    /// Save Locally the transaction
    /// - parameter trackTransaction: - Should the save transaction be tracked, so that it can be saved later to cloud
    /// - parameter idString: - An identifying string that will printed in the log file for debugging
    
    func saveLocally(_ trackTransaction: Bool, idString: String!) {
//        dlog("Saving Locally \(parseClassName)")
        
        pinInBackground(withName: ParsePin.Local.rawValue, block: nil)
//        pinWithName(ParsePin.Local.rawValue)
        
        if trackTransaction {
            dlog("Tracking \(parseClassName) Locally - \(idString)")
            pinInBackground(withName: ParsePin.SaveToCloud.rawValue, block: nil)
//            pinWithName(ParsePin.SaveToCloud.rawValue)
        }
        
    }

    /// Remove the record Locally and track transaction
    /// - parameter trackTransaction: - Should the save transaction be tracked, so that it can be saved later to cloud
    /// - parameter idString: - An identifying string that will printed in the log file for debugging
    
    func removeLocally(_ trackTransaction: Bool, idString: String!) {
        
        
        if trackTransaction {
            dlog("Removing with Tracker \(parseClassName) from Locally - \(idString)")
//            pinInBackgroundWithName(ParsePin.DeleteFromCloud.rawValue, nil)
            try! pin(withName: ParsePin.DeleteFromCloud.rawValue)
        }
        unpinInBackground(withName: ParsePin.SaveToCloud.rawValue, block: nil)
        unpinInBackground(withName: ParsePin.Local.rawValue, block: nil)
        
    }

}
//
//func ==(lhs: DWBaseParse, rhs: DWBaseParse) -> Bool {
//    return lhs.objectId? == rhs.objectId?
//}

