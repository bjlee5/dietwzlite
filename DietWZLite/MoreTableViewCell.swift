//
//  MoreTableViewCell.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 27/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var imgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureWithTableItem(_ infoItem: InfoItem, indexPath: IndexPath) {
        
        let dataItem = infoItem.dataItems()[(indexPath as NSIndexPath).row]
        let data = dataItem.data
        let icon = dataItem.icon
        
        titleLbl.text = data.rawValue
        imgLbl.font = UIFont.fontAwesomeOfSize(20)
        if let fontAwesomeValue = icon?.rawValue {
            imgLbl.text = String.fontAwesomeIconWithCode(fontAwesomeValue)
        }
        
//        if indexPath == NSIndexPath(forRow: 0, inSection: 3) {
//            
//            if Utils.sharedInstance.isPreviousDay || Utils.sharedInstance.dailyHistory.count < 2 {
//                titleLbl.textColor = UIColor.grayColor()
//                imgLbl.textColor = UIColor.grayColor()
//            } else {
//                titleLbl.textColor = UIColor.whiteColor()
//                imgLbl.textColor = UIColor.whiteColor()
//            }
//            
//        } else if indexPath == NSIndexPath(forRow: 1, inSection: 3) {
//            
//            if Utils.sharedInstance.isPreviousDay {
//                titleLbl.textColor = UIColor.whiteColor()
//                imgLbl.textColor = UIColor.whiteColor()
//            } else {
//                titleLbl.textColor = UIColor.grayColor()
//                imgLbl.textColor = UIColor.grayColor()
//            }
//        }
    }
}
