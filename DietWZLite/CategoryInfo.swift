//
//  CategoryInfo.swift
//  Moblzip
//
//  Created by Niklas Olsson on 18/11/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit
import Parse

class CategoryInfo: CategoryInfoAbstract, PFSubclassing {
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.Category.rawValue
    }
    
    class func definedCategories() -> [CategoryInfo] {
        return [
            SystemCategory.Fruits,
            SystemCategory.Veggies,
            SystemCategory.HealthySnacks,
            SystemCategory.SugarySnacks,
            SystemCategory.UnHealthyCarbs,
            SystemCategory.SugaryDrinks,
            SystemCategory.Alcohol,
            SystemCategory.Exercise,
            SystemCategory.Weight
        ]
    }
    
    /// call this mero
    class func getCategoryInfoObjectsFromPin(_ pin: String) -> [CategoryInfo]! {
        let localCategoryQuery = CategoryInfo.query()
        localCategoryQuery!.fromLocalDatastore()
//        localCategoryQuery!.fromPinWithName(pin)
        localCategoryQuery!.order(byAscending: "createdAt")
        localCategoryQuery!.whereKey("deleted", notEqualTo: true)
        
        //do a blocking  query, as this is needed for UI
        let localObjects: [AnyObject]! = try! localCategoryQuery!.findObjects()
        if localObjects == nil {
            return nil
        }        
        return localObjects.map{$0 as! CategoryInfo}
    }
}
