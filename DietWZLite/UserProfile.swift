//
//  DeviceInfo.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 28/10/14.
//  Copyright (c) 2015 Moblzip, LLC. All rights reserved.
//

import UIKit

class UserProfile: PFObject, PFSubclassing {
    
    @NSManaged var username: String
    @NSManaged var name: String
    @NSManaged var age: Int
    @NSManaged var gender: String
    @NSManaged var weight: Double
    @NSManaged var choicePointsLUD: Date
    @NSManaged var averageCyclePoints: Float //30 day average cycle points
    @NSManaged var dailyChoicePoints: Int
    @NSManaged var dailyCyclePoints: Int

    @NSManaged var userGroupPreferences: [UserGroupPreference]

    
    // empty constructor
    override init() {
        super.init()
    }
    
    func initializeData() {
        username            = ""
        name                = ""
        gender              = ""
        age                 = 0
        weight              = 0
        choicePointsLUD     = Date()
        averageCyclePoints  = 0
        dailyChoicePoints   = 0
        dailyCyclePoints    = 0
        userGroupPreferences = [UserGroupPreference]()
        
        let publicReadACL = PFACL()
        publicReadACL.getPublicReadAccess = true
        if let currentUser = PFUser.current() {
            publicReadACL.setWriteAccess(true, for: currentUser)
        } else {
            publicReadACL.getPublicWriteAccess = true
        }
        self.acl            = publicReadACL
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.UserProfile.rawValue
    }
        
}
