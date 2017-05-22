//
//  DetailCollectionViewCell.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 29/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    
    func configForIndex(_ indexPath: IndexPath) {
        
        titleLbl.backgroundColor = ThemeColors.Teal
        
        let currCycle = Utils.sharedInstance.getCurrCycle()
        
        let day1: DailyInfo = currCycle.first!
        var day2: DailyInfo
        
        if currCycle.count > 1 {
            day2 = currCycle[1]
        } else {
            day2 = DailyInfo()
            day2.userName = Utils.sharedInstance.userInfo.username
        }
        
        if currCycle.count == 1 && (indexPath as NSIndexPath).item == 2 {
            titleLbl.text = ""
            titleLbl.backgroundColor = UIColor.darkGray
            return
        }
        
        let activeDay = ((indexPath as NSIndexPath).item < 2) ? day1 : day2
        let firstColumn = ((indexPath as NSIndexPath).item == 0)
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            titleLbl.text =  firstColumn ? "" : "Day \((indexPath as NSIndexPath).row)"
            titleLbl.backgroundColor = UIColor.darkGray
            
        case 1:
            let mealWeight = MealWeight(rawValue: activeDay.breakfast)?.points ?? 0
            titleLbl.text =  firstColumn ? InfoItem.Data.Breakfast.rawValue : String(mealWeight)
            titleLbl.backgroundColor = UIColor.darkGray
            
        case 2:
            let mealWeight = MealWeight(rawValue: activeDay.lunch)?.points ?? 0
            titleLbl.text =  firstColumn ? InfoItem.Data.Lunch.rawValue  : String(mealWeight)
            titleLbl.backgroundColor = UIColor.darkGray
            
        case 3:
            let mealWeight = MealWeight(rawValue: activeDay.dinner)?.points ?? 0
            titleLbl.text =  firstColumn ? InfoItem.Data.Dinner.rawValue  : String(mealWeight)
            titleLbl.backgroundColor = UIColor.darkGray
    
        case 4...10:
            let aCategory = activeDay.categoryAry[(indexPath as NSIndexPath).section - 4]
            titleLbl.text =  firstColumn ? aCategory.label  : String(aCategory.getCategoryPoint())
            
        case 11:
            let aCategory = activeDay.categoryAry[(indexPath as NSIndexPath).section - 4]
            titleLbl.text =  firstColumn ? "Exercise?"  : String(aCategory.getCategoryPoint())
            
        case 12:
            titleLbl.text =  firstColumn ? "Daily Totals:"  : String(activeDay.getTotalPoint())
            titleLbl.backgroundColor = UIColor.orange
            
        default:
            break
        }
    }
    
}
