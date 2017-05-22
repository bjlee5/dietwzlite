//
//  NewsStoryCell.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 1/9/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//


import UIKit

class NewsStoryCell: UITableViewCell {
    
    @IBOutlet weak var txtUserName: UILabel!
    @IBOutlet weak var txtWeight: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtDailyPoints: UILabel!
    @IBOutlet weak var txtCyclePoints: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblDailyChoicePoints: UILabel!
    @IBOutlet weak var lblCyclePoints: UILabel!
    @IBOutlet weak var lblChoicePoints: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserGroupPreference(_ ugp: UserGroupPreference) {
        self.txtUserName.text = ugp.getUserName()
        
        self.txtDate.text       = "\(ugp.getUserChoicePointLUD().getShortDate())"
        
        if ugp.shareWeightPoints {
            self.txtWeight.text     = "\(ugp.getValueForColumn(.Weight, type: Float.self))"
        } else {
            self.lblWeight.isHidden = true
            self.txtWeight.isHidden = true
        }

        if ugp.shareDailyPoints {
            self.txtDailyPoints.text     = "\(ugp.getValueForColumn(.DailyChoicePoints, type: Int.self))"
        } else {
            self.lblDailyChoicePoints.isHidden = true
            self.txtDailyPoints.isHidden = true
        }

        if ugp.shareCyclePoints {
            self.txtCyclePoints.text     = "\(ugp.getValueForColumn(.DailyCyclePoints, type: Int.self))"
        } else {
            self.lblCyclePoints.isHidden = true
            self.txtCyclePoints.isHidden = true
        }
        
        if !ugp.shareCyclePoints && !ugp.shareDailyPoints {
            self.lblChoicePoints.isHidden = true
            self.lblDailyChoicePoints.isHidden = true
            self.txtDailyPoints.isHidden = true
            self.lblCyclePoints.isHidden = true
            self.txtCyclePoints.isHidden = true
        }
        
        viewBackground.layer.cornerRadius = 3.0
        viewBackground.layer.masksToBounds = false
        
        viewBackground.layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        viewBackground.layer.shadowOffset = CGSize(width: -0.20, height: 0.2)
        viewBackground.layer.shadowOpacity = 0.8
    }
}
