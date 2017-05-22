//
//  CategoryInfo.swift
//  Moblzip
//
//  Created by Niklas Olsson on 18/11/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit

class DailyCategoryInfo: CategoryInfoAbstract, PFSubclassing {
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.DailyCategory.rawValue
    }
    
    override func remove() {
        dlog("Removing \(parseClassName) Locally for id \(objectId)")
        unpinInBackground(withName: ParsePin.Local.rawValue, block: nil)
    }

    /// call this only from a background Thread
    class func getDailyCategoryInfoObjectsFromPin(_ pin: String) -> [DailyCategoryInfo]! {
        let localCategoryQuery = DailyCategoryInfo.query()!
//        localCategoryQuery.fromLocalDatastore()
        localCategoryQuery.fromPin(withName: pin)
        localCategoryQuery.order(byAscending: "createdAt")
        
        //do a blocking  query, as this is needed for UI
        let localObjects: [AnyObject]! = try! localCategoryQuery.findObjects()
        
        if localObjects == nil {
            return nil
        }

        return localObjects.map{$0 as! DailyCategoryInfo}
    }
}
