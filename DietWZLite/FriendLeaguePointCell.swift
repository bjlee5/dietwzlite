//
//  FriendLeaguePointCell.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 1/12/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation


import UIKit

class FriendLeaguePointCell: UITableViewCell {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblAvgPoints: UILabel!
    @IBOutlet weak var progressAvgPoints: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        progressAvgPoints.layer.cornerRadius = 5
        progressAvgPoints.clipsToBounds = true
        progressAvgPoints.layer.masksToBounds = true
//        progressAvgPoints.transform = CGAffineTransformScale(progressAvgPoints.transform, 1, 5)
//        progressAvgPoints.frame = CGRectMake(0, 0, 200, 15);
//        progressAvgPoints.bounds = CGRectMake(0, 0, 200, 15);

        
//        progressAvgPoints.layer.borderColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).CGColor
//        progressAvgPoints.layer.borderWidth = 1
        

//        
//        let gradientLayer = CAGradientLayer()
//
//        // 2
////        gradientLayer.frame = self.view.bounds
//        
//        // 3
//        let color1 = UIColor.yellowColor().CGColor as CGColorRef
//        let color2 = UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0).CGColor as CGColorRef
//        let color3 = UIColor.clearColor().CGColor as CGColorRef
//        let color4 = UIColor(white: 0.0, alpha: 0.7).CGColor as CGColorRef
//        gradientLayer.colors = [color1, color2, color3, color4]
//        
//        // 4
//        gradientLayer.locations = [0.0, 0.25, 0.75, 1.0]
//        
//        // 5
//        progressAvgPoints.layer.addSublayer(gradientLayer)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserGroupPreference(_ ugp: UserGroupPreference) {
        self.lblUserName.text = ugp.getUserName()
        let averagePoints = ugp.getValueForColumn(.AverageCyclePoints, type: Float.self)
        self.lblAvgPoints.text = "\(averagePoints)"
        progressAvgPoints.setProgress(averagePoints/20, animated: false)
    }
}
