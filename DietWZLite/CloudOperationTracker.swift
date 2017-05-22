//
//  OperationTracker.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 3/21/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

/// Instantiate this class to track either Save Operation or Delete Operation.
/// Since the operations are asynchronous, we need to delete locally after the cloud operations are complete
/// This is for tracking those operation during save or delete
/// CloudOperation(ParsePin.SaveToCloud) -- this will track save operation
/// CloudOperation(ParsePin.DeleteFromCloud) -- this will track delete operation
class CloudOperationTracker : CustomStringConvertible {
    
    var pinName = ""
    var category = false
    var dailyCategory = false
    var dailyInfo = false
    var description: String {
        return "\(pinName): Category=\(category), DailyCategory=\(dailyCategory), DailyInof=\(dailyInfo)"
    }
    fileprivate var executeLogout = false
    
    init() {
        
    }
    
    init(pinName: String) {
        self.pinName = pinName
    }
 
    func isComplete() ->  Bool {
        return category && dailyCategory && dailyInfo
    }
    
    /// Finish the operation, i.e., remove the tags from local datastore
    /// first see if all the objects are saved/deleted from cloud, then unpin objects
    fileprivate func checkAndUnpinAllObjects() {
        if isComplete() {
//            PFObject.unpinAllObjectsInBackgroundWithName(pinName, block: nil)
            PFObject.unpinAllObjectsInBackground(withName: pinName) {
                (succeded, err) -> Void in
                    dlog("[FINISH] \(self.pinName) - Removing all objects in the pin ")
                    if self.executeLogout && !Utils.sharedInstance.userInfo.logged {
                        self.executeLogout = false
                        //clean the histories, so that the next login users doesn't see the previous user's data
                        Utils.sharedInstance.dailyHistory.removeAll(keepingCapacity: false)
                        Utils.sharedInstance.categoryAry.removeAll(keepingCapacity: false)
                        PFUser.logOut()
                        //clean out usersession
                        Utils.sharedInstance.userInfo = UserSession()
                        dlog("======================== Logged out completed ***********")
                    }
            }
        }
    }
    
    /// this method helps in indicating that the cloud operation has completed, since it is a async operation, we have to mark them here.
    /// this will update flags in this tracker class, after all classes are complete it will delete all objects
    func done(_ className: ParseClassName) {
        dlog("\(pinName) for \(className.rawValue) is marked Done")
        
        switch className {
        case .DailyInfo:
            dailyInfo = true
        case .DailyCategory:
            dailyCategory = true
        case .Category:
            category = true
        default:
            break
        }
        
        checkAndUnpinAllObjects()
    }
    
    /// Use this method to start tracking, i.e., all the Parse Classes completiong status is set to false to indicate tracking
    func startTracking() {
        category = false
        dailyCategory = false
        dailyInfo = false
    }
    
    func startTracking(_ executeLogout: Bool) {
        startTracking()
        self.executeLogout = executeLogout
    }
}
