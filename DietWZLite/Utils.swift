//
//  Utils.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 27/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit
import HealthKit
import Async
import SCLAlertView


//import PermissionScope
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class Utils: NSObject {
    
    let DEFINED_COUNT = 9
    let CUSTOM_COUNT = 10
    let DISMISS_TIME: Double = 1.5
    
    let NOTIFICATION_NEW_DATE = "kNotificationNewDate"
    let NOTIFICATION_CATEGORIES_LOADED = "kNotificationCategoriesLoaded"
    let NOTIFICATION_DAILYINFO_LOADED = "kNotificationDailyInfoLoaded"
    let NOTIFICATION_FRIENDS_LOADED = "kNotificationUserGroupPreferenceLoaded"
    let NOTIFICATION_APPLICATION_ACTIVATED = "kNotificationApplicationActivated"
    let NOTIFICATION_NEW_MESSAGE = "kNewScrollingMessageAdded"
    
    let NOTIFICATION_LOADING_DATA_FROM_CLOUD = "Loading Data From Cloud"
    
    var scrollingMessage: String = ""
    
    var userInfo: UserSession = UserSession()
    var deviceInfo: DeviceInfo?
    var dailyHistory: [DailyInfo] = [DailyInfo]()
    var categoryAry: [CategoryInfo] = [CategoryInfo]()
//    var friendGroupArray: [FriendGroup] = [FriendGroup]()
    
    var userGroupPreferences: [UserGroupPreference] = [UserGroupPreference]()
    
    var APIRequestCount: Int = 1
    var incorrectPasswordCount = 5
    
    var isPreviousDay = false
    
    var parseSync = ParseSync()
    var itemsDownloadedFromCloud = CloudOperationTracker()
    
    let healthStore = HKHealthStore()
    let healthManager = HealthManager()
    
    
    class var sharedInstance: Utils {
        struct Static {
            static let instance: Utils = Utils()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }

    var appInCount:Int = 0
    //this method initialize, categories, history and newday
    func appInitialize() {
        resetIncorrectPasswordCount()
        dlog("********************** Utils appInitiazize called \(appInCount) ************")
        //Initialize the local variables, because the variables might be holding values from previous login. Since this is a shared class, initialize variables across logins and rebuild it.
        //logout is handling this.
//        dailyHistory.removeAll(keepCapacity: false)
//        categoryAry.removeAll(keepCapacity: false)
        dlog("dailyHistory - \(dailyHistory.count)")
        dlog("categoryAry - \(categoryAry.count)")
        Async.background {
            self.loadDeviceInfo()
        }
//        self.loadUserProfile()
        self.loadCategory()
        self.loadHistory()
//        Async.userInteractive{
            self.checkNewDay()
//        }
//        Async.background {
//            self.preLoadHealthyAlternative()
//        }
    }
    
    func resetIncorrectPasswordCount() {
        incorrectPasswordCount = 5
    }
    
    //this method is to track all the APIRequest going to cloud, we want to minimize the cloud requests that are being made.

    func apiRequest(_ operation: String) {
//        Async.background {
            self.APIRequestCount += 1;
            dlog(">>>>>>>>>>>> API Request Count = \(self.APIRequestCount)  >>>>> \(operation) from cloud")
//        }
    }
    
    func saveToParse() {
        //save weight to healthkit too
        saveWeightToHK()
        parseSync.saveToParse()
        //TODO: Create a parse job. It is possible that another device could have updated the cloud in the meanwhile
        //so we need to check and update selectively, if the LUD on local is greater than cloud only then sync
        //possibly write a pre-trigger on the cloud as a parse job
    }
    
    /*
    // MARK: - All Load Methods and their private helper methods
    */
    
    
    /// Pre Load Healthy Alternatives into Memory
//    private func preLoadHealthyAlternative() {
//        HealthyAlternatives.cacheHADB()
//    }
    
    
//    ///Load User Profile
//    func loadUserProfile() {
//        let deviceInfoQuery = UserProfile.query()!
//        deviceInfoQuery.fromLocalDatastore()
//                
//        let localObjects = try! deviceInfoQuery.findObjects()
//        if localObjects.count > 0 {
//            dlog("First Run for the user, hence Loading \(localObjects.count) DeviceInfo from local parse")
//            self.populateDeviceInfo(localObjects)
//        } else {
//            self.deviceInfo = DeviceInfo()
//            self.deviceInfo!.lastSyncDate = Date()
//            self.deviceInfo!.saveLocally()
//        }
//    }
    
    /// Load Device Info, to do delta sync later
    func loadDeviceInfo() {
        let deviceInfoQuery = DeviceInfo.query()!
        deviceInfoQuery.fromLocalDatastore()
        deviceInfoQuery.order(byDescending: "updatedAt")
        deviceInfoQuery.limit = 1
        
        let localObjects = try! deviceInfoQuery.findObjects()
        if localObjects.count > 0 {
            dlog("First Run for the user, hence Loading \(localObjects.count) DeviceInfo from local parse")
            self.populateDeviceInfo(localObjects)
        } else {
            self.deviceInfo = DeviceInfo()
            self.deviceInfo!.lastSyncDate = Date()
            self.deviceInfo!.saveLocally()
        }
    }
    
    fileprivate func populateDeviceInfo(_ objects: [AnyObject]) {
        var deviceInfo:DeviceInfo
        for obj in objects {
            deviceInfo = obj as! DeviceInfo
            self.deviceInfo =  deviceInfo
        }
    }

    
    /// Load Categories into the UI from local DB/App/Cloud and merge all three data
    func loadCategory() {
        dlog("Loading Categories")
        
        // query locally, if there is no data
        // then query cloud, if there is no data in cloud
        // then populate from defined catagories already in app and save locally to parse local
        // save in cloud will be done by Delta Sync Strategy
        
        let parseLocal:String = ParsePin.Local.rawValue
        dlog("Category info class name \(ParseClassName.Category.rawValue)")
        
        let localObjects = CategoryInfo.getCategoryInfoObjectsFromPin(parseLocal)!
        
        
        
        if localObjects.count > 0 {
//            dlog("Local categories = \(localObjects) ")
            dlog("Loading \(localObjects.count) Categories from local parse")
            self.categoryAry = localObjects
            
        } else {
            
            // since there is no data in local parse DB,
            // it means it is probably the first run, because the default categories don't have a ACL, so there has to be data in the local DB
            // since it is first run, see if we can load category from cloud synchronously
            
            if IJReachability.isConnectedToNetwork() {
                let cloudQuery = CategoryInfo.query()!
                cloudQuery.order(byAscending: "createdAt")
                cloudQuery.whereKey("deleted", notEqualTo: true)
                //            dlog("Getting categories from cloud")
                
                Utils.sharedInstance.apiRequest("**************   Load Category first run synchronously")
//                var cloudObjects = cloudQuery.findObjects()
                let cloudObjects = try! cloudQuery.findObjects()
                if cloudObjects.count > 0 {
                    PFObject.pinAll(inBackground: cloudObjects, block: nil)
                    self.categoryAry =  cloudObjects.map{$0 as! CategoryInfo}
                    return //we don't want to run the cloud query again, so return here
                } else {
                    // no data in the cloud
                    //  use the defined categories within the program
                    //now only populate the local storage
                    self.categoryAry = CategoryInfo.definedCategories()
//                    self.categoryAry.map{$0.saveLocally(false, idString: "\($0)")}
                    self.categoryAry.forEach {$0.saveLocally(false, idString: "\($0)")}
                }
            } else {
                // no network connections
                //use the defined categories within the program
                //now only populate the local storage
                self.categoryAry = CategoryInfo.definedCategories()
//                self.categoryAry.map{$0.saveLocally(false, idString: "\($0)")}
                self.categoryAry.forEach {$0.saveLocally(false, idString: "\($0)")}
            }
        }
        
        // if there is a network then go to cloud and fetch all the UI categories for this user.
        // There are three scenarios new, changed, missing or deleted
        // If new and is real add to local database
        // or if new category
        
//        Async.background {
            if IJReachability.isConnectedToNetwork() {
                let cloudQuery = CategoryInfo.query()
                cloudQuery!.order(byAscending: "createdAt")
                cloudQuery!.whereKey("deleted", notEqualTo: true)
                dlog("Getting categories from cloud for the sync routine")
                
                Utils.sharedInstance.apiRequest("Load Category")
                
                //run in background and consolidate with local DB
                cloudQuery!.findObjectsInBackground(block: { (cloudObjects, error) -> Void in
                    if error == nil {
                        if let cloudObjects = cloudObjects , cloudObjects.count > 0 {
                            //                    if cloudObjects!.count > 0 {
                            //                        dlog("Cloud categories = \(cloudObjects) ")
                            dlog("Loading \(cloudObjects.count) Categories from Cloud parse")
                            
                            //query all the category objects in the 'AddToCloud' pin, so that we could do the merge operation
                            var localObjectsInSaveToCloudPin = CategoryInfo.getCategoryInfoObjectsFromPin(ParsePin.SaveToCloud.rawValue)
                            
                            
                            var categoryCloudObject: CategoryInfo
                            for obj in cloudObjects {
                                categoryCloudObject = obj as! CategoryInfo
                                
                                //                            dlog("Checking the cloud category object \(categoryCloudObject.label)")
                                //if the cloud category object is found in the local category array then do nothing, otherwise add it to the local pin and category array
                                //if let _ = self.categoryAry.indexOf(categoryCloudObject) {
                                if let _ = categoryCloudObject.getIndex(self.categoryAry) {
                                    //                                dlog("Found the categoryObject so don't pin it \(categoryCloudObject.label)")
                                    //TODO: It is possible that other non key values might have changed in the cloud and may need to be synched, in that case compare timestamp
                                } else {
                                    dlog("Did not find the categoryObject \(categoryCloudObject.label) - \(categoryCloudObject.mode.rawValue)")
                                    //since this cloud category is not in local DB, we need to check if it is marked for deletion
                                    //handle if that category is deleted locally (i.e., marked for deletion)
                                    //Basically 'AddToCloud' pin will have this category with attribute 'deleted'
                                    
                                    //                                if let catAddToCloudIndex = localObjectsInSaveToCloudPin.indexOf(categoryCloudObject) {
                                    if let catAddToCloudIndex = categoryCloudObject.getIndex(localObjectsInSaveToCloudPin!) {
                                        // Since a match was found in SaveToCloud Pin and not in local DB, it means this category is marked for deletion
                                        
                                        //check both the timestamps and decide which is master
                                        
                                        let localSaveToCloudObject: CategoryInfo = localObjectsInSaveToCloudPin![catAddToCloudIndex]
                                        
                                        if categoryCloudObject.updatedAt > localSaveToCloudObject.updatedAt {
                                            // it means cloud is master, remove the delete tag, another device has added it back
                                            localSaveToCloudObject.deleted = false
                                            localSaveToCloudObject.unpinInBackground(withName: ParsePin.SaveToCloud.rawValue, block: nil)
                                            
                                            //                                        categoryCloudObject.pinInBackgroundWithName(ParsePin.Local.rawValue, block: nil)
                                            try! categoryCloudObject.pin(withName: ParsePin.Local.rawValue)
                                            self.categoryAry.append(categoryCloudObject)
                                            self.addToDailyHistory(categoryCloudObject)
                                        } //else {local is master and sync at shutdown will take care at the end}
                                        
                                    } else {
                                        //this is good, no conflicting data, simply add it to local and UI
                                        //                                    categoryCloudObject.pinInBackgroundWithName(ParsePin.Local.rawValue, block: nil)
                                        try! categoryCloudObject.pin(withName: ParsePin.Local.rawValue)
                                        self.categoryAry.append(categoryCloudObject)
                                        self.addToDailyHistory(categoryCloudObject)
                                    }
                                }
                            }
                            Async.main{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_NEW_DATE), object: nil)
                            }
                            //                        self.itemsDownloadedFromCloud.category = true
                        }
                    }
                })
            }
        
//        }
    }
    
    //add the new cateogry object to today and yesterdays category object, if it is not present.
    fileprivate func addToDailyHistory(_ category: CategoryInfo) {
        
        //find if the last history dailyinfo is same as today
        if self.dailyHistory.last!.date == Date.today() {
            // then add this category object to it
            // don't add duplicate object
            let todayDailyInfo = self.dailyHistory.last!
            let dailyCatInfoToday = DailyCategoryInfo(category: category)
            
            
//            if let _ = todayDailyInfo.categoryAry.indexOf(dailyCatInfoToday) {
            if let _ = dailyCatInfoToday.getIndex(todayDailyInfo.categoryAry) {
                dlog("Found the categoryObject so don't add it\(category.label)")
            } else {
                dlog("Adding \(category.label) to today daily info")
                todayDailyInfo.categoryAry.append( dailyCatInfoToday )
            }
            
            // see if previous day is present
            if dailyHistory.count > 1 {
                let previousDailyInfo = self.dailyHistory[dailyHistory.count - 2]
                let dailyCatInfoPrevious = DailyCategoryInfo(category: category)
//                if let _ = previousDailyInfo.categoryAry.indexOf(dailyCatInfoPrevious) {
                if let _ = dailyCatInfoPrevious.getIndex(previousDailyInfo.categoryAry) {
                    dlog("Found the categoryObject in previous day so don't add it\(category.label)")
                } else {
                    dlog("Adding \(category.label) to previous daily info")
                    previousDailyInfo.categoryAry.append( dailyCatInfoPrevious )
                }
            }
        }
        // else, checknewday will add this category
    }

    
    /// Load the history of dailyInfo for UI
    func loadHistory() {
        dlog("Loading history")
        let maxQueryLimit = 30
        
        // query locally, if there is no data
        // then query cloud, if there is no data in cloud
        // then populate from app and save locally
        // save in cloud will be done by Delta Sync Strategy
                
        let localObjects = DailyInfo.getDailyInfoObjectsFromPin(ParsePin.Local.rawValue)
        
        dlog("Local objects in daily history - \(localObjects?.count)")
        if localObjects != nil && localObjects?.count > 0 {
            dlog(">>>>>>>>>>>>>>>>>>> Loading \(localObjects?.count) DailyInfo from local parse")
//            dlog("*********** BEFORE local Objects count- \(self.dailyHistory.count)")
            if self.dailyHistory.count < 1 {
                self.dailyHistory += localObjects!
            }
//            dlog("*********** AFTER  local Objects count- \(self.dailyHistory.count)")
            //            self.populateDailyHistoryArray(localObjects)
        } else {
            

            
            //if there is no local objects, ideally we should be creating a new day
            //but we need to see if there is data on the cloud
            //ideally we can't block the operation
            //since this is first time, it is ok to block, from next time onwards the DeltaSync strategy should take care of it.
            //so see if there is network
            if IJReachability.isConnectedToNetwork() {
                Async.main{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_LOADING_DATA_FROM_CLOUD), object: nil)
                }
                let cloudQuery = DailyInfo.query()!
                cloudQuery.order(byDescending: "date")
                cloudQuery.includeKey("categoryAry")
                cloudQuery.limit = maxQueryLimit
                
                //this is blocking, because it is first run in the iphone, the next runs will go thru delta sync
                Utils.sharedInstance.apiRequest("Load DailyInfo History - synch - first run")
                do {
                    let cloudObjects = try cloudQuery.findObjects()
                    
                    if cloudObjects.count > 0 {
                        dlog(">>>>>>>>>>>>>>>>>>> Loaded \(cloudObjects.count) DailyInfo from cloud parse")
                        self.dailyHistory = [DailyInfo]()
                        self.dailyHistory += cloudObjects.map{$0 as! DailyInfo}
                        self.dailyHistory.sort(by: { $0.date < $1.date }) //ascending
                        PFObject.pinAll(inBackground: cloudObjects, withName: ParsePin.Local.rawValue, block: nil)
                        Async.main{
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_DAILYINFO_LOADED), object: nil)
                        }
                        return  //we don't want to run the cloud query again, so return here
                        //                    self.populateDailyHistoryArray(cloudObjects)
                    } else {
                        // nothing found in the cloud, which means it is a fresh installation
                        // create a new day
//                        dlog("No DailyInfo found in cloud, so creating a new day")
                        dlog("No DailyInfo found in cloud, so creating a new day")
                        createNewDay("No DailyInfo found in cloud, so creating a new day")
                    }
                } catch let error as  NSError {
                    //TODO: Need to test in airplane mode
                    let errorString = error.userInfo["error"] as! NSString
                    dlog("Error in getting dailyHistory from cloud \(errorString)")
                    // nothing found in the cloud, which means it is a fresh installation
                    // create a new day
//                    dlog("Error: No DailyInfo found in cloud, so creating a new day")
                    dlog("Specific Error: No DailyInfo found in cloud, so creating a new day")
                    createNewDay("Specific Error: No DailyInfo found in cloud, so creating a new day")
                }
                catch  {
                    derror("some generic error but still need to create a new day")
                    dlog("Generic Error: No DailyInfo found in cloud, so creating a new day")
                    createNewDay("Generic Error: No DailyInfo found in cloud, so creating a new day")
                }

                
            } else {
                // since the app is not connected to internet
                // and there is no history on the local DB
                // create a new dailyInfo that can be used here
//                dlog("No network connection, so creating a dailyinfo locally")
                dlog("No network connection, so creating a dailyinfo locally")
                createNewDay("No network connection, so creating a dailyinfo locally")
            }
//            dlog("*********** After normal CLOUD Sync dailyhistory count- \(self.dailyHistory.count)")
        }
        self.dailyHistory.sort(by: { $0.date < $1.date }) //ascending
        Async.main{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_DAILYINFO_LOADED), object: nil)
        }
//        Async.background {
            // now we got the UI going, now we will do the delta sync i.e., see if there is data on the cloud that needs to be synched to local db
            if IJReachability.isConnectedToNetwork() {
                
                
                let cloudQuery = DailyInfo.query()
                cloudQuery!.order(byDescending: "date")
                cloudQuery!.includeKey("categoryAry")
                cloudQuery!.limit = maxQueryLimit
                
                //            var cloudObjects = cloudQuery.findObjects()
                
                Utils.sharedInstance.apiRequest("Load DailyInfo History - asynch - Delta Sync")
                cloudQuery!.findObjectsInBackground(block: { (cloudObjects, error) -> Void in
                    if error == nil {
                        if let cloudObjects = cloudObjects , cloudObjects.count > 0 {
                            
                            //                    if cloudObjects != nil && cloudObjects.count > 0 {
                            dlog("Loaded \(cloudObjects.count) DailyInfo from cloud parse")
                            
                            
                            // Some times when the parse server is unavailable (i.e., it does not return correct data, but returns empty JSON data) it corrupts the dailyInfo object.
                            // this is to check if the data is correct, each row in parse has a field called username, that should match current user name, if not return
                            let cdiCheck = cloudObjects.last as! DailyInfo
                            if cdiCheck.userName != self.userInfo.username {
                                return
                            }
                            
                            
                            //loop thru each object and see if it is in the cloud, DELTA SYNC LOGIC, check each daily info with what is in local
                            // need to check all 31 objects, because graphs are based on it
                            for dailyInfo in cloudObjects {
                                let cloudDailyInfo = dailyInfo as! DailyInfo
                                
                                //                            if let catIndex = self.dailyHistory.indexOf(cloudDailyInfo) {
                                if let catIndex = cloudDailyInfo.getIndex(self.dailyHistory) {
                                    let localDailyInfo = self.dailyHistory[catIndex]
                                    if (cloudDailyInfo.updatedAt > localDailyInfo.updatedAt) {
                                        //then persist cloudDI as that is later than this one
                                        localDailyInfo.removeLocally(false, idString: "********* Cloud DailyInfo is master, hence removing this")
                                        cloudDailyInfo.saveLocally(false, idString: "Cloud DailyInfo is master")
                                        //in this case, it is possible that only few categories could have only changed and nothing in the daily info object
                                        // but it is ok to persist all of the categories from cloud daily info
                                        // it is also ok to remove all the categories from local daily info.
                                        dlog("*********** In Delta Sync - cloudDailyInfo won - \(cloudDailyInfo.date) - cloudDailyInfo \(cloudDailyInfo.updatedAt) - localDailyInfo \(localDailyInfo.updatedAt)")
                                        self.dailyHistory[catIndex] = cloudDailyInfo
                                    } // else {
                                    //since local is latest, nothing to do here
                                    //  }
                                } else {
                                    //this cloudDI not found locally, so persist it
                                    cloudDailyInfo.saveLocally(false, idString: "Cloud DailyInfo is not found locally, so saving")
                                    self.dailyHistory.append(cloudDailyInfo)
                                }
                            }
                            //sort dailyHistory after all the elements are added
                            //                        dlog("*********** In Delta Sync dailyhistory count- \(self.dailyHistory.count)")
                            
                            self.dailyHistory.sort(by: { $0.date < $1.date }) //ascending
                            Async.main{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_DAILYINFO_LOADED), object: nil)
                            }
                            for dailyInfo in self.dailyHistory {
                                if dailyInfo.choicePoints < 1 {
                                    dailyInfo.choicePoints = dailyInfo.getTotalPoint()
                                    if dailyInfo.choicePoints > 0 {
                                        dailyInfo.saveLocally()
                                    }
                                }
                            }
                        }
                    }
                })
            }
//        }
    }
    
    ///load friends from from local if true, else from cloud
    fileprivate func loadFriendsFromLocal(_ fromLocal: Bool) {
//        let userQuery = PFUser.query()!
        let userQuery = UserProfile.query()!
        let userProfileId = Utils.sharedInstance.userInfo.userProfile.objectId

//        userQuery.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        userQuery.whereKey("objectId", equalTo: userProfileId!)
        userQuery.includeKey("userGroupPreferences")
        userQuery.includeKey("userGroupPreferences.groupId")
        userQuery.includeKey("userGroupPreferences.groupId.friendUserIds")
        userQuery.includeKey("userGroupPreferences.groupId.friendUserIds.userProfile")
        
        
        if fromLocal {
            dlog("Getting friends from Local")
            userQuery.fromLocalDatastore()
        } else {
            Utils.sharedInstance.apiRequest("Loading friends async")
        }
        //            userQuery.orderByDescending("userGroupPreferences.groupId")
        
        
        userQuery.findObjectsInBackground(block: { (cloudObjects, error) -> Void in
            if error == nil {
                if let cloudObjects = cloudObjects , cloudObjects.count > 0 {
                    dlog("Loaded \(cloudObjects) UGP from \( fromLocal ? "Local" : "Cloud" ) parse")
                    if !fromLocal {
                        PFObject.pinAll(inBackground: cloudObjects, withName: ParsePin.Local.rawValue, block: nil)
                    }
                    let loadedUGP = (cloudObjects[0] as! UserProfile).mutableArrayValue(forKey: ParseColumnName.User.UGP.rawValue)
                    self.userGroupPreferences = [UserGroupPreference]()
                    for o in loadedUGP {
                        let ugp = o as! UserGroupPreference
                        dlog("friend group \(ugp.groupId)")
                        dlog("All friend UGP's in the group \(ugp.groupId.friendUserIds)")
//                        dlog("All UGP's in the group \(ugp.groupId.friendUserIds)")
                        ugp.cacheForUI()
                        self.userGroupPreferences.append(ugp)
                    }
                    
                    dlog("--------> FRIENDS CLOUD OBJECTS LOADED NOW, SENDING NOTIFICATION - \(cloudObjects.count)")
                    dlog("All UGP's \(self.userGroupPreferences)")
                    
                    Async.main{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_FRIENDS_LOADED), object: nil)
                    }
                } else {
                    dlog("LoadFriends: Nothing was loaded for this user")
                }
            } else {
                derror("Error loading friends - PFUser  \(error)" )
            }
        })
    }
    
    /**
     * Load all the groups and friends data
     */
    fileprivate func loadFriends() {
        dlog("Loading FRIENDS *****")
        // query locally,
        loadFriendsFromLocal(true)
        //irrespective of there is data in the local DB, check the cloud objects, just to make sure we are in sync
        Async.background{
            //if there is no local objects, check the cloud async
            if IJReachability.isConnectedToNetwork() {
                //TODO - getGroupFriendsData make a call and update the DB.
                self.loadFriendsFromLocal(false)
            } else {
                // since the app is not connected to internet
                // and there is no history on the local DB
                // TODO - BLOCK ICONS, if no network connection
                dlog("No network connection, so cannot get latest friend data, it is either blank or user from previous load")
            }
        }
    }
    
    
    
    //This method goes the cloud to see if there is any changes to the group info, i.e., have friends been added or admin changed
    // Don't worry about optimizing the requests here, because the cyclePoints always change, even if it is yesterday, a user could go back and complete yesterdays info.
    
    func checkForNewFriendsOrGroups() {
        loadFriends()
    }

    /// Remove the ugp from memory for the list.
    func removeUserGroupPreference(_ ugp: UserGroupPreference) {
        if let foundIndex = self.userGroupPreferences.index(of: ugp) {
            self.userGroupPreferences.remove(at: foundIndex)
        }
    }
    
    /**
    * This method is different from checkNewDay
    * This method will only be called if there is no history and a single new day is created
    */
    
    fileprivate func createNewDay(_ reason: String) {
        //don't create a new day if there is already something in history, the checkNewDay will fill the gap and create a new day
        if self.dailyHistory.count < 1 {
            let todayInfo = DailyInfo(categoryInfoArray: self.categoryAry)
            todayInfo.date = Date.today()
            todayInfo.cycleDay = 1 //1 since there is nothing in DailyHistory
            todayInfo.reason = reason
            todayInfo.saveLocally()
            self.dailyHistory.append(todayInfo)
        }
    }
    
    func loadHealthyAlternatives () {
        let query = PFQuery(className: "HealthyAlternatives")
        query.limit = 9999
        query.findObjectsInBackground { (objects, error) in
            if error != nil && error!._code != 101{
                derror("Error getting HealthyAlternatives objects \(error)")
            } else {
                dlog("HealthyAlternatives from parse \(objects?.count)")
                
                PFObject.unpinAllObjectsInBackground(withName: "HealthyAlternatives", block: { (success, error) -> Void in
                    dlog("Unpining healthy alternatives inside")
                    PFObject.pinAll(inBackground: objects, withName: "HealthyAlternatives", block: nil)
                })
            }
        }
    }
    
    func loadRecipes() {
        let query = PFQuery(className: ParseClassName.Recipes.rawValue)
        query.findObjectsInBackground { (objects, error) in
            if error != nil && error!._code != 101{
                derror("Error getting Recipes objects \(error)")
            } else {
                dlog("Recipes from parse \(objects?.count)")
                
                PFObject.unpinAllObjectsInBackground(withName: ParseClassName.Recipes.rawValue, block: { (success, error) -> Void in
                    dlog("Unpining Recipes inside")
                    PFObject.pinAll(inBackground: objects, withName: ParseClassName.Recipes.rawValue, block: nil)
                })
            }
        }
    }
    
    fileprivate func loadVersionControl (_ newVersion: Bool, oldVersionControlObjectLocal: PFObject!) {
        
        var oldvHADB:Float = 0
        var oldvRecipe:Float = 0

        if(!newVersion) {
            oldvHADB = oldVersionControlObjectLocal["HealthyAlternativeVersion"] as! Float
            oldvRecipe = oldVersionControlObjectLocal["RecipeVersion"] as! Float
        }
        // go get it from parse
        let query = PFQuery(className: ParsePin.VersionControl.rawValue)
        query.getFirstObjectInBackground { (versionControlObjectParse, error) in
            if error != nil {
                derror("Error getting VersionControl from Parse  \(error)")
            } else {
//                dlog(">>>oldVersionControlObjectLocal objects \(oldVersionControlObjectLocal)")
//                dlog("versionControlObjectParse objects \(versionControlObjectParse)")
                
                if(!newVersion) {
                    if let versionControlObjectParse = versionControlObjectParse {
                        
                        let newvHADB = versionControlObjectParse["HealthyAlternativeVersion"] as! Float
                        let newvRecipe = versionControlObjectParse["RecipeVersion"] as! Float
                        
                        dlog("oldv \(oldvHADB), newv \(newvHADB),  oldvRecipe \(oldvRecipe) , newvRecipe \(newvRecipe) ")
                        
                        if newvHADB > oldvHADB {
                            // Delete existing local version control
                            PFObject.unpinAllObjectsInBackground(withName: ParsePin.VersionControl.rawValue, block: { (success, error) -> Void in
                                try! versionControlObjectParse.pin(withName: ParsePin.VersionControl.rawValue)
                                self.loadHealthyAlternatives ()
                            })
                        }
                        
                        if newvRecipe > oldvRecipe {
                            PFObject.unpinAllObjectsInBackground(withName: ParsePin.VersionControl.rawValue, block: { (success, error) -> Void in
                                try! versionControlObjectParse.pin(withName: ParsePin.VersionControl.rawValue)
                                self.loadRecipes()
                            })
                        }
                        
                    }
                } else {
                    try! versionControlObjectParse!.pin(withName: ParsePin.VersionControl.rawValue)
                    self.loadHealthyAlternatives ()
//                    self.loadRecipes()
                }
            }
        }
    }
    
    /// Check version control - so that any app info is loaded in the cloud could be loaded here.
    func checkVersionControl() {
        dlog("Checking Version Control")
        // step 1 check app versions are updated locally
        let versionControlQuery = PFQuery(className: ParsePin.VersionControl.rawValue)
        versionControlQuery.fromLocalDatastore()
        versionControlQuery.getFirstObjectInBackground { (versionControlObjectLocal, error) in
            if error != nil && error!._code != 101 {
                derror(">>>>>>  Error getting versionControlQuery objects from local \(error)")
            } else {
                self.loadVersionControl(versionControlObjectLocal == nil, oldVersionControlObjectLocal: versionControlObjectLocal)
            }
        }
    }
    
    func getCurrDay() -> DailyInfo {
        if isPreviousDay && dailyHistory.count > 1 {
            return dailyHistory[dailyHistory.count - 2]
        } else {
            return dailyHistory.last!
        }
    }
    
    func getCurrDayIndex() -> Int {
        return getCurrDay().cycleDay
    }
    
    /// get both the dailyinfo based on cycleday
    func getCurrCycle() -> [DailyInfo] {
        
        if dailyHistory.last!.cycleDay == 2 {
            return [dailyHistory[dailyHistory.count - 2], dailyHistory.last!]
        } else {
            return isPreviousDay ? [dailyHistory[dailyHistory.count - 3], dailyHistory[dailyHistory.count - 2]] : [dailyHistory.last!]
        }
    }
    
    /// get choicePoints, i.e., 2 day cycle points (this should have been choice points
    func getCyclePoints() -> Int {
        return getCurrCycle().map({ $0.getTotalPoint() }).reduce(0, +)
    }
    
    
    // go back each day from today
    // identify cycle day from today
    // pop stack once
    //      if cycle day is 1
    //          cycle point for just today
    //
    //      if cycle day is 2
    //          pop another day
    //          cycle point for last 2 days
    
    // loop for exactly 15 times
    
    /// get last 15, 2-day choice points
    func getLast15ChoicePoints() -> [Double] {
        var activeIdx = dailyHistory.count - 1
        var pointsAry: [Double] = []
        var points = 0
        var dailyInfo = dailyHistory[activeIdx]
        
        for _ in 0...14 {
            dailyInfo = dailyHistory[activeIdx]
            points = dailyInfo.getTotalPoint()
            activeIdx -= 1;
            if activeIdx < 0 {
                pointsAry.insert(Double(points), at: 0)
                break
            }
            if dailyInfo.cycleDay == 2 {
                dailyInfo = dailyHistory[activeIdx]
                points += dailyInfo.getTotalPoint()
                activeIdx -= 1;
                if activeIdx < 0 {
                    pointsAry.insert(Double(points), at: 0)
                    break
                }
            }
            pointsAry.insert(Double(points), at: 0)
        }
        
        return pointsAry
    }
    
    func addCategory(_ category: CategoryInfo) {
        if categoryAry.count > DEFINED_COUNT+CUSTOM_COUNT {
            return
        }
        dlog("Adding a new Category \(category)")
        category.saveLocally()

        categoryAry.append(category)
        
        let dailyCategory = DailyCategoryInfo(category: category)
        dailyCategory.saveLocally()
        
        let todayInfo = dailyHistory.last!
        todayInfo.categoryAry.append(dailyCategory)
        todayInfo.saveLocally()

    }
    
    func removeCategoryFromArray(_ category: CategoryInfo) {
        if category.userDefined {
            let index = categoryAry.index{$0.label == category.label && $0.mode == category.mode}

            if index >= 0 {
                let catInfo = categoryAry.remove(at: index!)
                catInfo.remove()
                
                let todayInfo: DailyInfo = dailyHistory.last!
                let dailyCategories = todayInfo.categoryAry
                
                let dailyCatIndex = dailyCategories.index {$0.label == category.label && $0.mode == category.mode}
                //(DailyCategoryInfo(category: category))
                
                if dailyCatIndex >= 0 {
                    let dailycat = todayInfo.categoryAry.remove(at: dailyCatIndex!)
                    dlog("Removed daily cat \(dailycat)")
                    todayInfo.saveLocally()
                }
            }
        }
    }
    
    
    //Reset current day, it does not reset the cycle, if the user is on second day, he stays in second day, all the lunch and daily categories will reset.
    func resetCurrDay() {
        let todayInfo = dailyHistory.last!
        todayInfo.reset()
        todayInfo.saveLocally()
    }
    
    /**
    // Reset the current cycle and start over
    // i.e., if it is second day make it day 1 one and start over
    // if it is day 1, the below will still work, i.e., simply reset today.
    2 day cycle reset
    1. Just delete today's i.e., day 2
    2. Create a new day today and make it as day 1
    3. Yesterday's cycle day will remain as cycle day 1
    4. TODO: Yesterday's cycle day point should be 0
    
    What if the user is editing the previous day and wants to reset it?
    - In the app, bring him forward and startover, don't start over from yesterday.
    */
    func resetCurrCycle() {
        self.isPreviousDay = false  // Bring them to current day first
        
        let lastDay = self.dailyHistory.last!
        let lastDayCycleDay = lastDay.cycleDay
        
        lastDay.reset()
        lastDay.cycleDay = 1
        lastDay.saveLocally()
        let count = self.dailyHistory.count
        
        if lastDayCycleDay == 1 && count > 1 {
            //reset both days
            let secondLastDay = self.dailyHistory[count-2]
            secondLastDay.reset()
            secondLastDay.cycleDay = 1
            secondLastDay.saveLocally()
        }
        
        showSuccessNotification("Cycle has been reset")
    }
    
    /**
     * 
    This method clears the history and creates a new day
    
     //TODO: Implement the cloud delete function in case of reset of an app.
     i.e., each and every daily info should be deleted from the cloud for this user
     make sure you log the time and device this was requested from.
     */
    func resetAll() {
        self.dailyHistory = [DailyInfo]()
        dlog("Reset All")
        createNewDay("Reset All")
    }
    
    /**
        Clean up the local datastore
        * Remove DailyInfo from the history for more than 30 days
        * Remove Deleted Categories
     */
    func cleanUpDataStore() {
        //TODO Complete cleanup after other bug fixes
        Async.background {
            
        }
    }
    
    func checkNewDay() {
        
        dlog("Checking for new day History Count -\(self.dailyHistory.count)")
        
        
//        let calendar = NSCalendar.currentCalendar()
        let lastDay = dailyHistory.last!  //UTC - change this to local before comparision
        
        let now = Date() //LOCAL -

        //TODO:  convert the cloud UTC data to local timezone's midnight
        // and then compare with local timezone's current time.
        // figure out the delta
        // ************ make sure the delta is less than 24hrs, if it is longer, then there might be intermediates
        
        //
        var lastDate = Date(timeInterval: 24*60*60, since: lastDay.date as Date)
        var isNewDate = false
        var numberOfDaysAdded = 0;

        var cycleDay = lastDay.cycleDay == 1 ? 2 :1
        while lastDate.compare(now) == .orderedAscending {
            //TODO: check for conflict resolution in case of slow loading of dailyinfo from cloud, 
            //it is possible that we are creating a new day, whereas some other device might have created that day from somewhere else in cloud, and when we bring it back, be intelligent about keeping the cloud one and deleting the local one, otherwise the local one redundantly is save in cloud and may cause issues in average choice points calculations.
            let newDay = DailyInfo(categoryInfoArray: self.categoryAry)
            newDay.date = lastDate
            newDay.cycleDay = cycleDay
            newDay.reason = "\(numberOfDaysAdded). checkNewDay: New day added(\(lastDate))"
            dlog(newDay.reason)
            newDay.saveLocally()
            dailyHistory.append(newDay)
            cycleDay = cycleDay == 1 ? 2 :1
            isNewDate = true
            numberOfDaysAdded += 1
//            dlog("\(numberOfDaysAdded). checkNewDay: New day added(\(lastDate))")
            lastDate = Date(timeInterval: 24*60*60, since: lastDate)
        }
        
        if isNewDate {
            //TODO - Check for yesterday's DailyInfo entry and if it is blank, give them an option to fill out the entries for yesterday
//            Async.main{
//            UIAlertView(title: "", message: "New day has been started!", delegate: nil, cancelButtonTitle: "Ok").show()
//                showSuccessNotification("New day has been started!")
                showNewDayStarted()
                NotificationCenter.default.post(name: Notification.Name(rawValue: self.NOTIFICATION_NEW_DATE), object: nil)
//            }
        }
        dlog("fillWeightFromYesterday  going to call History Count - \(self.dailyHistory.count)")
        fillWeightFromYesterday()
        checkPoints()
        checkForNewFriendsOrGroups()
    }
    
    /// fill weight from yestereday 
    /// since a new day is created
    /// fill all the new dates
    /// with wieght from one valid data
    fileprivate func fillWeightFromYesterday() {
        dlog("fillWeightFromYesterday  called \(self.dailyHistory.count)")
        
        if dailyHistory.last?.getWeight() < 1 {
            
            var previousWeight:Double = 0
            var firstNonZeroWeight:Double = 0
            //        var firstNonZeroWeightIndex = 0
            
            var lastNonZeroWeight:Double = 0
            var lastNonZeroWeightIndex = 0
            
            for index in 0...self.dailyHistory.count-1 {
                let dailyInfo = dailyHistory[index]
                var weight = dailyInfo.getWeight()
                if weight > 0 {
                    previousWeight = weight
                    
                    if firstNonZeroWeight < 1 {
                        firstNonZeroWeight = previousWeight
                        //                    firstNonZeroWeightIndex = index
                    }
                    lastNonZeroWeight = weight
                    lastNonZeroWeightIndex = index
                    
                    //                dlog("first non zero weight \(dailyInfo.date)  - weight \(previousWeight) - index \(index) - lastIndex \(lastNonZeroWeightIndex)")
                    
                } else if previousWeight > 0  {
                    weight = previousWeight
                }
            }
            
            //fill the non-zero values from last non zero weight, until today (instead of yesterday)
            for index in lastNonZeroWeightIndex...self.dailyHistory.count-1 {
                let dailyInfo = dailyHistory[index]
                var weight = dailyInfo.getWeight()
                if weight < 1 {
                    dailyInfo.setWeight(lastNonZeroWeight)
                    dailyInfo.saveLocally(true, idString: " \(dailyInfo.date) populating weight")
                    weight = lastNonZeroWeight
                }
            }
        }
        
        getWeightFromHKUpdateDailyHistory()

    }
    
    /// update weight from HK into dailyHistory, this should be called only after daily history is loaded either from local or cloud
    fileprivate func getWeightFromHKUpdateDailyHistory() {
        //get Today's weight and set the weight in dailyHistory
        getTodaysWeightFromHK { (wtFromHK, error) -> Void in
            if error == nil && wtFromHK > 0 {
                self.dailyHistory.last?.setWeight(wtFromHK!)
                Async.main{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_DAILYINFO_LOADED), object: nil)
                }
            }
        }
    }
    
    /// get today's weight from Healthkit, this method is only called if HK data is available
    func getTodaysWeightFromHK(_ completion: ((Double?, NSError?) -> Void)!){
        var wt = 0.0;
        if !HKHealthStore.isHealthDataAvailable() {
            return
        }
        
        healthManager.authorizeHealthKit { (success, error) -> Void in
            if success {
                dlog("HK authorized")
                //TODO: FIX THE DISTANTPAST TO LUD for the weight
                self.healthManager.readMostRecentSample(HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!, startDate: Date.distantPast)  { (mostRecentWeight, error) -> Void in
                    if error != nil {
                        derror("Error retrieving value from HK - \(error?.localizedDescription)")
                        completion(0, error)
                        return
                    }
                    
                    if mostRecentWeight == nil {
//                        let errorNoWeight = NSError(domain: "com.dietwz", code: 2, userInfo: [NSLocalizedDescriptionKey:"No Weight Data Found"])
                        completion(0, nil)
                        return
                    }
                    
                    let mrw = mostRecentWeight as? HKQuantitySample;
                    wt = (mrw?.quantity.doubleValue(for: HKUnit.pound()))!
                    dlog("Weight from HK - \(wt)")
                    completion(wt, nil)
                }
            } else {
                derror("HK was not authorized")
                let errorNoWeight = NSError(domain: "com.dietwz", code: 2, userInfo: [NSLocalizedDescriptionKey:"HK was not authorized"])
                completion(0, errorNoWeight)
            }
        }
        
    }
    
    //save weight in lbs to healthkit
    func saveWeightToHK() {
        if HKHealthStore.isHealthDataAvailable() {
            getTodaysWeightFromHK { (wtFromHK, error) -> Void in
                if error == nil {
                    let latestWeight = self.dailyHistory.last?.getWeight()
                    if latestWeight == nil || latestWeight < 0.1 {
                        return
                    }
                    dlog(">>>>>>>>>>>>  latestWeight \(latestWeight), wtFromHK - \(wtFromHK) ")
                    if latestWeight != wtFromHK {
                        dlog("Updating weight in health kit")
                        self.healthManager.writeWeight(latestWeight!, date: Date())
                    }
                }
            }
        }
    }
    
    /// register start new day notification, so at midnight if the app is open, the alert pops up.
    func registerNotifiacation() {
        let localNotification = UILocalNotification()
        localNotification.alertAction = "Start new day"
        localNotification.alertBody = ""
        
        let calendar = Calendar.current
        let now = Date()
        let currComp = (calendar as NSCalendar).components([.year, .month, .day], from: now)
        var startComp = DateComponents()
        startComp.year = currComp.year
        startComp.month = currComp.month
        startComp.day = currComp.day
        
        localNotification.fireDate = calendar.date(from: startComp)!
        
        localNotification.repeatInterval = NSCalendar.Unit.day
        UIApplication.shared.cancelAllLocalNotifications()
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        dlog("Notification Registered \(localNotification)")
    }
    
    func checkPoints() {
        dailyHistory.last?.cycleDay == 1 ? checkForCycle1() : checkForCycle2()
//        if (dailyHistory.count % 2) == 1 {
//            checkForCycle1()
//        } else {
//            checkForCycle2()
//        }
    }
    
    // Cloud code to update Average cycle point with latest daily info
    // This should be invoked on the last Daily Info object.
//    func updateUserGroupData() {
//        PFCloud.callFunctionInBackground("updateGroupData", withParameters: ["userName": self.userInfo.username]) {
//            (response: AnyObject?, error: NSError?) -> Void in
//            if error == nil {
//                let res = response as? String
//                dlog("Average cycle points \(res) in cloud")
//            } else {
//                derror("\(error)")
//            }
//        }
    
    /// return 30 day average cycle points
    func getAverageCyclePoints() -> Float {
        return Float(round(10 * Utils.sharedInstance.getLast15ChoicePoints().average)/10)
    }
    
    //todo: delete this
    func delay(_ delay: Double, closure: @escaping ()->()!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure as! @convention(block) () -> Void)
    }
    
    func checkForCycle1() {
        let todayInfo = dailyHistory.last!
        let point = todayInfo.getTotalPoint()
        
        switch point {
        case 0..<5:
            replaceScrollingMessage("Make healthy choices to earn points. 8 daily points or more is a good day.")
        case 5..<8:
            replaceScrollingMessage("You’re doing well making healthy choices – keep it up!")
        default:
            replaceScrollingMessage("Great job of making healthy choices!")
        }
    }
    
    func checkForCycle2() {
        (arc4random() % 2) == 1 ? messageCategory2() : messageCategory3()
    }
        
    /** 
     This method appends to a scrolling message to the home screen
     */
    func addScrollingMessage(_ message: String) {
        self.scrollingMessage = self.scrollingMessage + " " +  message
    }
    
    /**
    This method replaces the scrolling message on the home screen
    */
    func replaceScrollingMessage(_ message: String) {
        self.scrollingMessage = message
        Async.main{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NOTIFICATION_NEW_MESSAGE), object: nil)
        }
    }
    
    func messageCategory2() {
        let todayInfo = dailyHistory.last!
        let point = todayInfo.getTotalPoint()
        
        switch point {
        case 0..<8:
            replaceScrollingMessage("Make healthy choices to earn points. 8 daily points or more is a good day.")
        case 8..<11:
            replaceScrollingMessage("Nice job so far this cycle – keep making healthy choices.")
        case 11..<16:
            replaceScrollingMessage("Great job with your choices!")
        default:
            replaceScrollingMessage("EXCELLENT: You’re making lots of healthy choices!")
        }
    }
    
    func messageCategory3() {
        let todayInfo = dailyHistory.last!
        let point = todayInfo.getTotalPoint()
        
        if point < 6 {
            replaceScrollingMessage("Remember: each daily serving of a fruit or vegetable is worth 1 point.")
        } else {
            if todayInfo.categoryAry[3].point <= -2 {
                replaceScrollingMessage("You might want to cut back on sugary snacks.")
            } else if todayInfo.categoryAry[7].point <= 0 {
                replaceScrollingMessage("Try to get some kind of physical exercise every day.")
            } else if todayInfo.categoryAry[6].point <= -1 {
                replaceScrollingMessage("Consider cutting back on alcohol.")
            } else if todayInfo.categoryAry[0].point <= 2 {
                replaceScrollingMessage("Fruits are a healthy diet choice.")
            } else if todayInfo.categoryAry[1].point <= 2 {
                replaceScrollingMessage("Vegetables are a healthy diet choice.")
            } else if todayInfo.categoryAry[4].point <= -2 {
                replaceScrollingMessage("Consider cutting back on unhealthy carbs.")
            } else {
                messageCategory2()
            }
        }
    }
    
    
    func getDietWzTitleString(_ scale: Int) ->  NSMutableAttributedString {
        
        let smallSize: CGFloat = CGFloat(10 * scale)
        let largeSize: CGFloat = CGFloat(20 * scale)
        
        let font: UIFont? = UIFont(name: "Helvetica Neue", size: largeSize)
        let fontSuper: UIFont? = UIFont(name: "Helvetica Neue", size: smallSize)
        let attString: NSMutableAttributedString = NSMutableAttributedString(string: "DietWZTM", attributes: [NSFontAttributeName:font!])
        attString.setAttributes([NSFontAttributeName:fontSuper!,NSBaselineOffsetAttributeName:10*scale], range: NSRange(location:6,length:2))
        return attString
    }
    
    func showNoInternetDialog(msg: String) {
        
        let resetAlert = SCLAlertView()
        let subTitle = msg
        let title = "No Internet?"
        resetAlert.showWarning(title, subTitle: subTitle, closeButtonTitle: "Cancel", timeout: nil
            , colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
        
    }
    
    func getPublicReadUserWriteACL() -> PFACL {
        let publicReadACL = PFACL()
        publicReadACL.getPublicReadAccess = true
//        publicReadACL.setPublicReadAccess(true)
        if let currentUser = PFUser.current() {
            publicReadACL.setWriteAccess(true, for: currentUser)
        }
        return publicReadACL
    }
    
    
    
    /// Public can Read and Write on this object
    func getPublicReadWriteACL() -> PFACL {
        let publicReadWriteACL = PFACL()
        publicReadWriteACL.getPublicReadAccess = true
        publicReadWriteACL.getPublicWriteAccess = true
        
//        publicRe¡adWriteACL.setPublicReadAccess(true)
//        publicReadWriteACL.setPublicWriteAccess(true)
        return publicReadWriteACL
    }
    
}
