//
//  Recipes.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 10/15/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

class Recipes: DWBaseParse, PFSubclassing {
    
    @NSManaged var name: String
    @NSManaged var recipeHTML: String
    @NSManaged var category: String
    
    override init() {
        super.init()
    }
    
    convenience init(healthyAlternatives: HealthyAlternatives) {
        self.init()
        self.recipeHTML = healthyAlternatives.recipeHTML
        self.name = healthyAlternatives.itemDescrip
        self.category = healthyAlternatives.itemCat
    }
    
    class func parseClassName() -> String {
        return ParseClassName.Recipes.rawValue
    }
    
    class func loadAllForTableView1(_ category: String) -> [Recipes]! {
        let localQuery = PFQuery(className: ParseClassName.Recipes.rawValue)
        localQuery.fromLocalDatastore()
        localQuery.order(byAscending: "name")
        if category != "All" {
            localQuery.whereKey("category", equalTo: category)
        }
        
        let localObjects = try! localQuery.findObjects()
        let localHAObjs: [Recipes] = localObjects.map {$0 as! Recipes}
        return localHAObjs
    }
    
    
    class func loadAllRecipesCategories() -> [String]! {

        let localQuery = PFQuery(className: ParseClassName.Recipes.rawValue)
        localQuery.fromLocalDatastore()
        localQuery.order(byAscending: "name")
        
        let localObjects = try! localQuery.findObjects()
        
        var resultArray: [String] = []
        var catArray = Set<String>()
        catArray.insert("All")
        resultArray.append("All")
        
        // since parse doesn't have a mechanism for groupby or distinct, we need to filter them out
//        if let localObjects = localObjects {
            for o in localObjects {
                let itemCat = o["category"] as! String
                if !catArray.contains(itemCat) {
                    catArray.insert(itemCat)
                    resultArray.append(itemCat)
                }
            }
//        }
        return resultArray
    }
}

func ==(lhs: Recipes, rhs: Recipes) -> Bool {
    return lhs.name == rhs.name
}
