//
//  UserGroupPreference.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 8/15/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

class UserGroupPreference: DWBaseParse, PFSubclassing {

    
//    @NSManaged var user: PFUser
    @NSManaged var userProfile: UserProfile
    @NSManaged var groupId: FriendGroup
    @NSManaged var status: String
    @NSManaged var shareDailyPoints: Bool //Daily Choice Points
    @NSManaged var shareCyclePoints: Bool //Total Choice Points at the end of each 2­day cycle
    @NSManaged var shareWeightPoints: Bool

    var friendsUGP = [UserGroupPreference]()
    var friendsNewsUGP = [UserGroupPreference]()
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    override func saveLocally() {
        super.saveLocally(true, idString: "for \(groupId.groupName) - \(userProfile.username)")
    }
    
    func getValueForColumn<T>(_ userColumnName: ParseColumnName.User, type: T.Type) -> T {
        
        if let value = userProfile[userColumnName.rawValue] {
            
            if self.userProfile == Utils.sharedInstance.userInfo.userProfile {
                
                switch userColumnName {
                case .DailyChoicePoints:
                    return Utils.sharedInstance.dailyHistory.last!.choicePoints as! T //Int
                case .DailyCyclePoints:
                    return Utils.sharedInstance.getCyclePoints() as! T //Int
                case .Weight:
                    return Float(Utils.sharedInstance.dailyHistory.last!.getWeight()) as! T //Float
                case .AverageCyclePoints:
                    return Float(Utils.sharedInstance.getAverageCyclePoints()) as! T //Float
                default:
                    fatalError("should not call case: \(userColumnName)")
                }
                
            } else {
                return value as! T
            }
            
        } else {
            return 0 as! T
        }
    }
    
    /// when were the choices updated.
    func getUserChoicePointLUD() -> Date {
        
        guard let userChoicePointLUD: Date = self.userProfile[.ChoicePointsLUD] as? Date else {
            return Date()
        }
        
        return userChoicePointLUD
    }
    
    /// get user name
    func getUserName() -> String {
//        dlog("username from userprofile \(userProfile)")
        return self.userProfile.username
        
//        guard let userName: String = self.userProfile[.UserName] as? String else {
//            //TODO:Ideally this should not show up in the graph.
//            return ""
//        }
//        return userName
    }
    
    func leaveGroup() {
        self.groupId.removeUserGroupPreference(self)
    }
    
    func isInvited() -> Bool {
        return status == UserGroupStatus.Invited.rawValue
    }
    
    // is the current user an admin in this group?
    func isAdmin() -> Bool {
        return groupId.admin == self.userProfile
//        return groupId.adminId == self.user
    }
    
    func cacheForUI() {
        self.friendsUGP = self.groupId.friendUserIds
        self.friendsNewsUGP = self.friendsUGP
        self.friendsUGP.sort(by: {$0.getValueForColumn(.AverageCyclePoints, type: Float.self) > $1.getValueForColumn(.AverageCyclePoints, type: Float.self)})
        self.friendsNewsUGP.sort(by: {$0.getUserChoicePointLUD().isGreaterThanDate($1.getUserChoicePointLUD())})
    }

    // MARK: - Class methods
    
    class func parseClassName() -> String {
        return ParseClassName.UserGroupPreference.rawValue
    }
    
    /// call this only from a background Thread
    class func getUserGroupPreferenceFromPin(_ pin: String) -> [UserGroupPreference]! {
        
        let localQuery = PFQuery(className: ParseClassName.UserGroupPreference.rawValue)
        localQuery.fromPin(withName: pin)
        
        localQuery.order(byAscending: "groupId")
        localQuery.includeKey("groupId")
        localQuery.includeKey("groupId.friendUserIds")
        
        let localObjects = try! localQuery.findObjects()
        
        dlog("UserGroupPreferences localobjects from local: \(localObjects)")
        
        var userGroupPrefArray = [UserGroupPreference]()

        for o in localObjects {
            userGroupPrefArray.append(o as! UserGroupPreference)
        }

        dlog("UserGroupPreferences from local: \(userGroupPrefArray)")
        return userGroupPrefArray
    }
    
}
