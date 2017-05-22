//
//  HealthyAlternatives.swift
//  Moblzip
//
//  Created by Sujit Maharana on 4/17/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation


/*


{
"itemComment":"Low-cal snack with protein",
"itemDescrip":"Corn chips and hummus",
"itemPic":"default",
"itemId":300,
"itemProtein":4,
"createdAt":"2015-04-17T23:29:13.544Z",
"itemCat":"Snack",
"itemSugar":0,
"itemLipidTot":16,
"updatedAt":"2015-04-17T23:29:13.544Z",
"__complete":true,
"itemKcal":230,
"objectId":"bJ9n4IjS2S",
"itemServing":"1 oz (2 tbsp) hummus and 1 oz low-sodium corn chips",
"itemFiber":2,
"itemSodium":230,
"className":"HealthyAlternatives",
"itemCalFat":136,
"itemSatFat":2,
"ItemChol":0,
"isDeletingEventually":0,
"ItemMono":0,
"itemCarbs":20,
"__operations":[{"__uuid":"7BD7305A-7AF0-471C-A996-6D2981BCB94E"}],
"ItemPoly":0
}

*/

class HealthyAlternatives: DWBaseParse, PFSubclassing {
    
    @NSManaged var itemCat: String
    @NSManaged var itemDescrip: String
    @NSManaged var itemComment: String
    @NSManaged var itemPic: String
    @NSManaged var itemServing: String

//    @NSManaged var itemPic: String
    
    
    @NSManaged var itemProtein: Float
    @NSManaged var itemSugar: Int
    @NSManaged var itemLipidTot: Float
    @NSManaged var itemKcal: Int
    @NSManaged var itemFiber: Float
    @NSManaged var itemSodium: Int
    @NSManaged var itemCalFat: Int
    @NSManaged var itemSatFat: Float
//    @NSManaged var itemCalFat: Int
    @NSManaged var ItemChol: Int
    @NSManaged var ItemMono: Float
    @NSManaged var itemCarbs: Int
    @NSManaged var ItemPoly: Float
    
    @NSManaged var recipeHTML: String
    
    fileprivate static var HACategories = [String]()
    fileprivate static var AllHealthyAlternatives = [HealthyAlternatives]()
    
    override init() {
        super.init()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.HealthyAlternatives.rawValue
    }
    
    
    // Search view controller needs data from HealthyAlternatives table
    class func loadAllForTableView1(_ healthyAlternativeCateogory: String) -> [HealthyAlternatives]! {
        if healthyAlternativeCateogory != "All" {
            return AllHealthyAlternatives.filter{ $0["itemCat"] as! String == healthyAlternativeCateogory}
        } else {
            return AllHealthyAlternatives
        }
    }
    
    /** 
        Load all categories from the healthy alternatives DB
     */
    class func loadAllHealthyAlternativeCategories() -> [String]! {
        if HACategories.isEmpty {
            cacheHADB()
        }
        return HACategories
    }
    
    class func cacheHADB() {
        
        if HACategories.isEmpty || HACategories.isEmpty {
        
            let localQuery = PFQuery(className: ParseClassName.HealthyAlternatives.rawValue)
            localQuery.fromLocalDatastore()
            localQuery.order(byAscending: "itemDescrip")
            let localObjects = try! localQuery.findObjects()
            
            //Cache HealthyAlternatives
            AllHealthyAlternatives = localObjects.map {$0 as! HealthyAlternatives}
            
            //Find Categoreies and cache them
            var resultArray: [String] = []
            var catArray = Set<String>()
            catArray.insert("All")
            resultArray.append("All")
            
            // since parse doesn't have a mechanism for groupby or distinct, we need to filter them out
            //        if let localObjects = localObjects {
            for o in localObjects {
                let itemCat = o["itemCat"] as! String
                if !catArray.contains(itemCat) {
                    catArray.insert(itemCat)
                    resultArray.append(itemCat)
                }
            }
            //        }
            HACategories = resultArray
        }
    }
}

func ==(lhs: HealthyAlternatives, rhs: HealthyAlternatives) -> Bool {
    return lhs.itemDescrip == rhs.itemDescrip
}
