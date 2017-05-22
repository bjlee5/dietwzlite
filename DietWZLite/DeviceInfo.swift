//
//  DeviceInfo.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 28/10/14.
//  Copyright (c) 2015 Moblzip, LLC. All rights reserved.
//

import UIKit

class DeviceInfo: DWBaseParse, PFSubclassing {
    
    @NSManaged var lastSyncDate: Date
    
    
    // empty constructor
    override init() {
        super.init()
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.DeviceInfo.rawValue
    }
    
}
