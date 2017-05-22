//
//  FriendGroup.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 8/15/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation
import Async


class FriendGroup: DWBaseParse, PFSubclassing {
    
    @NSManaged var friendUserIds: [UserGroupPreference]  //this is a list of accepted users
    @NSManaged var invitedUserEmails: [String]  //this is a list of invited users, just emai
//    @NSManaged var adminId: PFUser
    @NSManaged var groupName: String
    @NSManaged var admin: UserProfile
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.FriendGroup.rawValue
    }
    
    override func saveLocally() {
        super.saveLocally(true, idString: "for \(groupName)")
    }
    
    func invite(_ email: String) {
        //TODO - save the friend group to the cloud first, then let them invite.
        //TODO - send email from cloud backend
        PFCloud.callFunction(inBackground: "addEmailToFriendGroup", withParameters: ["email": email.lowercased(), "friendGroupId": self.objectId!])
        {
            (response: Any?, error: Error?) in
            if error == nil {
                let ratings = response as? String
                dlog("Email Saved \(ratings)")
            } else {
                dlog("\(error)")
            }
            Utils.sharedInstance.checkForNewFriendsOrGroups()
            NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
            
        }
        
        
        // call the cloud function to do the post processing of adding email to UGP
        //TODO: Find the parse user for the invited email,
        //create a usergrouppreference for that user and mark the status invited, do this in save eventually callback
        // for the users that are not present in the system, write a routine during user signup.
        // in aftersave logic, to query each group and create a UGP
        
        //TODO: When cancelling invitation, remove the corresponding userGroupPref
        
//        self.saveEventually( {
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//                //TODO: check user is not nil and then execute UGP
//                let user = self.getUserForEmail(email)
//                let ugp: UserGroupPreference = UserGroupPreference()
//                ugp.status = "invited"
//                ugp.userName = user.username!
//                ugp.user = user
//                ugp.groupId = self
//                
//                
//            } else {
//                // There was a problem, check error.description
//            }
//        })
        
    }
    
    /// Given an email address, get the associated user
//    fileprivate func getUserForEmail(_ email: String) -> PFUser {
//        let qry = PFUser.query()!
//        qry.whereKey("email", equalTo: email)
//        let user: PFUser = (try! qry.getFirstObject() as? PFUser)!
//        return user
//    }
    
    /// get the usernames, for all the active users in friendUserIds, they are pointer to UGP, so go another level deep
    func getActiveFriendList() -> [String] {
        return friendUserIds.map({ $0.userName })
    }
    
    /// Remove the accepted user from this group, basically delete the UGP for this user, remove both pointers from friendGroup and User
    func removeUser(_ index: Int) {
        //remove the UGP for the user here
        let ugp: UserGroupPreference = friendUserIds[index]
        removeUserGroupPreference(ugp)
    }
    
    /// Removes a UGP from this group, given the actual UGP object, maybe passed from main frield table ui
    func removeUserGroupPreference(_ ugp: UserGroupPreference) {
        
        let currentUserProfile = Utils.sharedInstance.userInfo.userProfile
        
//        if self.adminId == currentUser {
        if self.admin == Utils.sharedInstance.userInfo.userProfile {
            //this user is admin user, hence pass on the groups to another user
            if friendUserIds.count < 2 {
                //this means the group has only the admin and he wants to leave the group, 
                //so remove the group too.
                Utils.sharedInstance.removeUserGroupPreference(ugp)
                currentUserProfile.removeObject(ugp, forKey: ParseColumnName.User.UGP)
                currentUserProfile.saveInBackground()
                
                //TODO: Delete this offline too, this will be a problem in airplane mode.
                
                
                //do all of these in the background including delete the group and admin ugp
                dlog("Single admin user in this group - so the group itself is deleted in background")
                ugp.deleteInBackground()
                self.deleteInBackground()
                
            } else {
                // make the next user as admin and then delete the objects.
                
                dlog("BEFORE: Admin User \(admin)")
//                self.adminId = (self.friendUserIds[1]).user //assuming 0th position is the admin user, the next will become admin
                self.admin = (self.friendUserIds[1]).userProfile //assuming 0th position is the admin user, the next will become admin
                dlog("AFTER: Admin User \(admin)")
                
                removeUGP(ugp, currentUser: currentUserProfile)
            }
        } else {
            // this user is not admin, so simply remove this UGP from group
            removeUGP(ugp, currentUser: currentUserProfile)
        }
    }
    
    fileprivate func removeAllUGP() {
        //TODO:  DELETEALLINBACKGROUND will work, after you remove them user profile
    }
    
    /// Private convinence method to remove the UGP from this group, remove the ugp from current user, delete ugp, save user and save self(group)
    fileprivate func removeUGPDeleteMe(_ ugp: UserGroupPreference, currentUser: PFUser) {
        
        currentUser.removeObject(ugp, forKey: ParseColumnName.User.UGP)
        currentUser.saveInBackground()
        
        dlog("friends before deleting \(friendUserIds.count)")
        self.removeObject(ugp, forKey: ParseColumnName.FriendGroup.FriendUserIds)
        self.saveInBackground()
        dlog("friends after deleting \(friendUserIds.count)")
        
        Utils.sharedInstance.removeUserGroupPreference(ugp)
        ugp.deleteInBackground()
        dlog("removed ugp, user-ugp, group-ugp, has been fired")
        
    }
    
    fileprivate func removeUGP(_ ugp: UserGroupPreference, currentUser: UserProfile) {
        
        currentUser.removeObject(ugp, forKey: ParseColumnName.User.UGP)
        currentUser.saveInBackground()
        
        dlog("friends before deleting \(friendUserIds.count)")
        self.removeObject(ugp, forKey: ParseColumnName.FriendGroup.FriendUserIds)
        self.saveInBackground()
        dlog("friends after deleting \(friendUserIds.count)")
        
        Utils.sharedInstance.removeUserGroupPreference(ugp)
        ugp.deleteInBackground()
        dlog("removed ugp, user-ugp, group-ugp, has been fired")
        
    }
    
    func cancelInvite(_ index: Int) {
        self.removeObject(invitedUserEmails[index] as AnyObject, forKey: ParseColumnName.FriendGroup.InvitedUserEmails)
        self.saveEventually(nil)
    }
}
