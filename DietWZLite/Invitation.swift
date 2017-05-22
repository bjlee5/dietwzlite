//
//  Invitation.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 8/15/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

class Invitation: DWBaseParse, PFSubclassing {
    
    @NSManaged var email: String
    @NSManaged var friendGroupId: FriendGroup
    @NSManaged var userId: PFUser
    @NSManaged var status: String //accepted, user_not_in_system
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.Invitation.rawValue
    }
    
    override func saveLocally() {
        super.saveLocally(true, idString: "for \(email)")
    }
    
}