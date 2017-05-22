//
//  DailyInfo.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 28/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

//class DailyInfo: PFObject, PFSubclassing {
class DailyInfo: DWBaseParse, PFSubclassing {
    
//    @NSManaged var userName: String
    @NSManaged var breakfast: Int
    @NSManaged var lunch: Int
    @NSManaged var dinner: Int
    @NSManaged var categoryAry: [DailyCategoryInfo]
    @NSManaged var date: Date
    @NSManaged var cycleDay: Int
    @NSManaged var choicePoints: Int
    @NSManaged var reason:String
    
//    var cycleDay1: Int {
//        get {
//            if self["cycleDay"] == nil {
//                return 2
//            } else {
//                return self["cycleDay"] as! Int
//            }
//        }
//        set(newValue) {
//            dlog("Trying to set cycleday \(newValue)  -  \(parseClassName)")
//            if newValue == 0 {
//                dlog("Going Here")
//                self["cycleDay"] = 0
//            } else {
//                dlog("Going there")
//                self["cycleDay"] = newValue
//            }
//        }
//    }

    
//    static let weightCategory: DailyCategoryInfo = DailyCategoryInfo(userDefinedCategory: false, mode: CategoryMode.Weight, label: Constants.CategoryLabels.Weight)
    
    /** 
     * Method to initalize all variables, so that it can be called from various initalizers
     */
    fileprivate func initializeData() {
        breakfast = -1
        lunch = -1
        dinner = -1
        categoryAry = Array()
        userName = Utils.sharedInstance.userInfo.username
//        date & cycleDay is not initialized because, the caller needs to set for which date is this DailyInfo is
//        date = NSDate()
        cycleDay = 1
        reason = ""
    }
    
    // empty constructor
    override init() {
        super.init()
        // initalizing data in default constructor has caused me a lot of pain.
        // Parse bombs with no good error, it generally happens after adding a field in parse and the downloading other rows that has nil value in those fields
        // I believe it happens during pinning the data.
//        initializeData()
    }
    
    /** 
     * Constructor that takes an array of Category Info and convert it into DailyCategory Info and add it to the DailyInfo object
     */
    
    init(categoryInfoArray: [CategoryInfo]) {
        super.init()
        initializeData()
        
        categoryAry = categoryInfoArray.map({ DailyCategoryInfo(category: $0 as CategoryInfo) })

//        for obj in categoryInfoArray {
//            let dailyCategoryInfo = DailyCategoryInfo(category: obj as CategoryInfo)
//            categoryAry.append(dailyCategoryInfo)
//        }
    }
    
    override class func initialize() {
        superclass()?.load()
        self.registerSubclass()
    }
    
    class func parseClassName() -> String {
        return ParseClassName.DailyInfo.rawValue
    }
    
    func setMealValue(_ dataItem: InfoItem.Data, mealWeight: MealWeight) {

        switch dataItem {
        case .Breakfast:
            breakfast = mealWeight.rawValue
        case .Lunch:
            lunch = mealWeight.rawValue
        case .Dinner:
            dinner = mealWeight.rawValue
        default:
            break
        }
    }
    
    func mealWeightForDataItem(_ dataItem: InfoItem.Data) -> Int? {
        switch dataItem {
        case .Breakfast:
            return breakfast
        case .Lunch:
            return lunch
        case .Dinner:
            return dinner
        default:
            return nil
        }
    }
    
    /** 
     * This method gets the total point for all system defined categories
     * This ignore user defined category
     */
    func getTotalPoint() -> Int {

        var total = [breakfast, lunch, dinner].flatMap({ MealWeight(rawValue: $0)?.points }).reduce(0, +)

        for dailyCategory in self.categoryAry where !dailyCategory.userDefined {
            total += dailyCategory.getCategoryPoint()
        }
        
        return total
    }
    
    func reset() {
        breakfast = -1
        lunch = -1
        dinner = -1
        categoryAry.forEach{ $0.reset() }
    }
    
    override func saveLocally() {
        self.choicePoints = self.getTotalPoint()
        super.saveLocally(true, idString: "for \(date)")
//        Utils.sharedInstance.parseSync.debugPrintForPin(ParsePin.SaveToCloud.rawValue)
    }
    
    /// call this only from a background Thread
    class func getDailyInfoObjectsFromPin(_ pin: String) -> [DailyInfo]! {
        
        let localQuery = PFQuery(className: ParseClassName.DailyInfo.rawValue)
//        localQuery.fromLocalDatastore()
        localQuery.fromPin(withName: pin)
        
        localQuery.order(byAscending: "date")
        localQuery.includeKey("categoryAry")
//        localQuery.limit = 32 //no limit as we want last date at the end of the array
        
        var dailyInfoArray = [DailyInfo]()
        do {
            let localObjects = try localQuery.findObjects()
            for o in localObjects {
                dailyInfoArray.append(o as! DailyInfo)
            }
        } catch {
            //no issues, if there is nothing in the pin
        }
//        let localObjects = try! localQuery.findObjects()
//        if localObjects == nil {
//            return nil
//        } else {
//            var dailyInfoArray: [DailyInfo] = [DailyInfo]()
//            for o in localObjects {
//                dailyInfoArray.append(o as DailyInfo)
//            }
//            
//        }
        
//        var dailyInfoArray: [DailyInfo] = [DailyInfo]()
//        if let localObjects = localObjects {
//            for o in localObjects {
//                dailyInfoArray.append(o as! DailyInfo)
//            }
//        }

        return dailyInfoArray
    }
    
    
    /// Find the category for this day, given a category type.
    func getCategory(_ catInfo: CategoryInfo) -> DailyCategoryInfo {
//        dlog("Step where it fails \(self.date)")
//        dlog("\(self.categoryAry)")
//        dlog("self.cat count - \(self.categoryAry.count)")
        
        for cat in self.categoryAry where cat.equals(catInfo) {
            return cat
        }
        
        return DailyCategoryInfo(category: catInfo)
    }
    
    
    /// get weight for this day
    func getWeight() -> Double {
        return Double(getCategory(SystemCategory.Weight).value)
    }
    
    /// set weight for this day
    func setWeight(_ weight: Double) {
        getCategory(SystemCategory.Weight).value = Float(weight)
    }

    // To do: figure out why equatable stop working after upgrade
    func equals(_ rhs: DailyInfo) -> Bool {
        return self.date == rhs.date
    }
    
    /// this method returns the index of this daily info object in the array passed
    func getIndex(_ dailyInfoArray: [DailyInfo]) -> Int? {
//        return dailyInfoArray.indexOf {self.equals($0)}
        return dailyInfoArray.index {self.date == $0.date}
    }
    
}

func ==(lhs: DailyInfo, rhs: DailyInfo) -> Bool {
    return lhs.date == rhs.date
}
