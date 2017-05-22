//
//  ParseSync.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 3/21/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation


class ParseSync {
    
    /// this field tracks all the cloud save operation
    fileprivate var cloudSave = CloudOperationTracker(pinName: ParsePin.SaveToCloud.rawValue)
    /// this field tracks all the cloud delete operation
    fileprivate var cloudDelete = CloudOperationTracker(pinName: ParsePin.DeleteFromCloud.rawValue)
    var inProgress = false

    // sync and save to parse
    func saveToParse() {
        dlog("Saving everything to parse")
        debugPrintForPin(.SaveToCloud)
        debugPrintForPin(.Local)
        //1. Delete Objects from cloud
        //2. Add Objects to cloud
        if IJReachability.isConnectedToNetwork() {
            self.inProgress = true
            deleteFromCloud()
            saveToCloud()
        }
    }
    

    /// MARK: Save
    //1. Save Category objects
    //2. Save DailyCategory objects
    //3. Save DailyInfo Objects
    //4. Remove all the objects from Local that were deleted in session - happens automatically after the async methods are completed
    fileprivate func saveToCloud() {
        cloudSave.startTracking(true)
        saveToCloudWithClassNames([.Category, .DailyInfo, .UserGroupPreference])
        //if a DailyInfo is found then daily categories are automatically saved/deleted, no need to make an additional API call
        //hence commenting the below line and calling from the async block
        //        saveToCloudWithClassName(.DailyCategory)
    }
    
    fileprivate func saveToCloudWithClassNames(_ classNames: [ParseClassName]) {
        
        for className in classNames {
            
            let query = PFQuery(className: className.rawValue)
            query.fromPin(withName: ParsePin.SaveToCloud.rawValue)
            query.findObjectsInBackground {(objects, error) -> Void in
                
                if error != nil {
                    dlog("Error occured: EEEEE NO Cloud Save for class: \(className) Error:\(error)")
                } else if objects == nil {
                    dlog("No Objects: NNNNN NO Cloud Save for class: \(className)")
                } else if objects!.count > 0 {
                    
                    Utils.sharedInstance.apiRequest("[SavingToCloud]: \(objects!.count)  \(className)")
                    do {
                        dlog("Objects to save - \(objects) ")
                        try PFObject.saveAll(objects)
                    } catch let error as NSError {
                        dlog("\(error)")
                        dlog("\(error.localizedDescription)")
                    }
                    catch _ {
                        derror("Error: while saving to cloud, doing nothing, we will take care on next sync")
                        return
                    }
                    dlog(">>>>>>>>>>>>> Saved to cloud : \(objects!.count)  \(className)")
                    self.cloudSave.done(className)
                    
                    //if a DailyInfo is found then daily categories are automatically saved, no need to make an additional API call
                    // just mark the tracker cor DailyCategory Complete
                    if className == .DailyInfo {
                        self.cloudSave.done(.DailyCategory)
                        
                        let todayInfo = Utils.sharedInstance.dailyHistory.last!
                        let currentUserSession = Utils.sharedInstance.userInfo
                        
                        currentUserSession.dailyCyclePoints     = Utils.sharedInstance.getCyclePoints() //2-day points
                        currentUserSession.weight               = todayInfo.getWeight()
                        currentUserSession.dailyChoicePoints    = todayInfo.choicePoints //this is one day cyclepoint
                        currentUserSession.choicePointsLUD      = Date()
                        currentUserSession.averageCyclePoints   = Utils.sharedInstance.getAverageCyclePoints() // 30 day average cycle points
                        currentUserSession.save()
                        
                    }
                } else {
                    dlog("0 Objects: 00000 NO Cloud Save for class: \(className)")
                    // if no Daily Info was found, make sure to save the Daily Categories explicitly
                    if className == .DailyInfo {
                        self.saveToCloudWithClassNames([.DailyCategory])
                    }
                    self.cloudSave.done(className)
                }
                
            }
        }
    }
    
    /// MARK: Delete
    //--
    
    /// Delete all objects from cloud that are marked for Delete by various operation
    
    //1. Delete Category objects
    //2. Delete DailyCategory objects
    //3. Delete DailyInfo Objects
    //4. Remove all the objects from Local that were deleted in session - happens automatically after the async methods are completed
    fileprivate func deleteFromCloud() {
        cloudDelete.startTracking()
        deleteFromCloudWithClassNames([.Category, .DailyInfo, .DailyCategory, .UserGroupPreference])
    }
    
    /// Delete all the data from cloud for this classname
    fileprivate func deleteFromCloudWithClassNames(_ classNames: [ParseClassName]) {
        //        dlog("Cloud Delete: \(objects.count) objects of class \(className)")
        
        for className in classNames {
            
            let query = PFQuery(className: className.rawValue)
            query.fromPin(withName: ParsePin.DeleteFromCloud.rawValue)
            query.findObjectsInBackground { (objects, error) -> Void in
                
                if error != nil {
                    dlog("Error occured: EEEE NO Cloud Delete for class: \(className) Error:\(error)")
                } else if objects == nil {
                    dlog("No Objects: 0000 NO Cloud Delete for class: \(className)")
                } else if objects!.count > 0 {
                    
                    Utils.sharedInstance.apiRequest("[DeletingFromCloud]: \(objects!.count) \(className)")
                    //                dlog("[DeletingFromCloud]: \(objects.count) \(className)")
                    PFObject.deleteAll(inBackground: objects, block: {(success, error) -> Void in
                        if(success) {
                            self.cloudDelete.done(className)
                        }
                    })
                } else {
                    dlog("0 Objects: 0000 NO Cloud Delete for class: \(className)")
                    self.cloudDelete.done(className)
                }
            }
        }
    }
    
    /// MARK: Debug
    //-----
    
    /**
     Print all the data in all the tables for the pins that is passed
     @param pin Name of the pin it could be(SaveToCloud, DeleteFromCloud, Local)
    */
    func debugPrintForPin(_ pin: ParsePin) {
        printPins( pin, classNames: [.DailyCategory, .DailyInfo, .Category])
    }
    
    /// Print all the data for the given pin and given class/table name
    /// @pin: the name of pins
    /// @className: class name or table name
    fileprivate func printPins(_ pin: ParsePin, classNames: [ParseClassName]) {
  
        for className in classNames {

            let query = PFQuery(className: className.rawValue)
            query.fromPin(withName: pin.rawValue)
            query.findObjectsInBackground { (objects, error) -> Void in
                if error == nil && objects != nil && objects!.count > 0 {
                    dlog("[ObjectsInPin] >>>> \(pin) - \(className): \(objects!.count)")
                } else {
                    dlog("[ObjectsInPin] 0000 \(pin) - \(className): 0")
                }
            }
        }
    }
}
