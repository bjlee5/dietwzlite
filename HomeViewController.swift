//
//  HomeViewController.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 23/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit
import Async

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, HomeTableViewCellDelegate {

    var todayInfo: DailyInfo!
    
    var infoItems = [InfoItem(infoTitle: .DailyChoices)]
    lazy var sectionZeroRowCount: Int = self.infoItems[0].dataItems().count - 3 //this is to account for meals not really being category items, this should really be fixed
    
    @IBOutlet weak var dietwzTitleLabel: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var cycleIndicatorLbl: UILabel!
    @IBOutlet weak var totalBtn: UIButton!
    @IBOutlet weak var tableViw: UITableView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblMessage: MarqueeLabel!
    
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dietwzTitleLabel.attributedText = Utils.sharedInstance.getDietWzTitleString(1)

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newDateStarted(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_NEW_DATE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newDateStarted(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_CATEGORIES_LOADED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newDateStarted(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_DAILYINFO_LOADED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newMessageArrived(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_NEW_MESSAGE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.gettingDataFromCloudMessage(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_LOADING_DATA_FROM_CLOUD), object: nil)
        
        lblUserName.text = Utils.sharedInstance.userInfo.username
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notifications
    
    func newDateStarted(_ notification: Notification?) {
        refreshData()
    }
    
    func newMessageArrived(_ notification: Notification?) {
        lblMessage.textColor = UIColor.white
        lblMessage.text = Utils.sharedInstance.scrollingMessage
    }
    
    func gettingDataFromCloudMessage(_ notification: Notification?) {
        lblMessage.textColor = UIColor.blue
        lblMessage.text = Utils.sharedInstance.NOTIFICATION_LOADING_DATA_FROM_CLOUD
    }
    
    // MARK: - Actions
    
    @IBAction func onInfo(_ sender: UIButton) {
        showInfoForDataItem(InfoItem.Data.AboutUs)
    }
    
    @IBAction func onDecreaseCategory(_ sender: UIButton) {
        let index = sender.tag
        let aCategory = todayInfo.categoryAry[index]
        if aCategory.value < 1 {
            return
        }
        
        aCategory.value -= 1
        aCategory.saveLocally()
        self.todayInfo.saveLocally()
        
        var section = 0, row = 0
        if index < sectionZeroRowCount {
            section = 0
            row = index + 3
        } else {
            section = 1
            row = index - sectionZeroRowCount
        }
        self.tableViw.reloadRows(at: [IndexPath(row: row, section: section)], with: UITableViewRowAnimation.automatic)
        self.totalBtn.setTitle("\(self.getCyclePoints())", for: UIControlState())

    }
    
    @IBAction func onIncreaseCategory(_ sender: UIButton) {
        let index = sender.tag
        let aCategory = todayInfo.categoryAry[index]
        
        if index >= sectionZeroRowCount && aCategory.value >= aCategory.limit {
            return
        }
        
        aCategory.value += 1
        aCategory.saveLocally()
        todayInfo.saveLocally()
        
        var section = 0, row = 0
        if index < sectionZeroRowCount {
            section = 0
            row = index + 3
        } else {
            section = 1
            row = index - sectionZeroRowCount
        }
        tableViw.reloadRows(at: [IndexPath(row: row, section: section)], with: UITableViewRowAnimation.automatic)
        totalBtn.setTitle("\(getCyclePoints())", for: UIControlState())
    }
    
    @IBAction func onStatusItem(_ sender: UISegmentedControl) {
        let index = sender.tag
        let aCategory = todayInfo.categoryAry[index]
        var value = sender.selectedSegmentIndex
        if value == UISegmentedControlNoSegment {
            value = -1
        }
        aCategory.value = Float(value)
        aCategory.saveLocally()
        todayInfo.saveLocally()
        
        totalBtn.setTitle("\(getCyclePoints())", for: UIControlState())
    }
    
    /// get choicePoints, i.e., 2 day cycle points (this should have been choice points
    func getCyclePoints() -> Int {
        return Utils.sharedInstance.getCyclePoints()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return todayInfo.categoryAry.count > sectionZeroRowCount ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3 + sectionZeroRowCount
        } else {
            return todayInfo.categoryAry.count - sectionZeroRowCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var dataItem: InfoItem.Data?
        
        var index = (indexPath as NSIndexPath).row - 3
        if (indexPath as NSIndexPath).section == 1 {
            index = sectionZeroRowCount + (indexPath as NSIndexPath).row
        } else {
            
            dataItem = infoItems[(indexPath as NSIndexPath).section].dataItems()[(indexPath as NSIndexPath).row].data
            
            if (indexPath as NSIndexPath).row < 3 {
                let mealCell = tableView.dequeueReusableCell(withIdentifier: "MultiChoiceCell") as! HomeTableViewCell
                mealCell.delegate = self
                mealCell.configForMultichoice(dataItem!)
                return mealCell
            }
        }
                
        let category: CategoryInfoAbstract = todayInfo.categoryAry[index]
        let cellIdentifier = category.mode.stringValue + "Cell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HomeTableViewCell
        cell.configWithCategory(category, index: index, indexPath: indexPath, dataItem: dataItem, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row < 3 {
            return 70
        }
        
        var index = (indexPath as NSIndexPath).row - 3
        if (indexPath as NSIndexPath).section == 1 {
            index = sectionZeroRowCount + (indexPath as NSIndexPath).row
        }

        let aCategory: CategoryInfoAbstract = todayInfo.categoryAry[index]
        switch aCategory.mode {
//        case .MultiChoice:
//            return 70
        case .counter:
            return (indexPath as NSIndexPath).section == 0 ? 55 : 65
        case .question:
            return 65
        case .weight:
            return 100
        case .numeric:
            return 65
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerViw = UIView()
        headerViw.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 25)
        headerViw.backgroundColor = UIColor.darkGray;
        
        let headerLbl: UILabel = UILabel()
        headerLbl.frame = headerViw.bounds
        headerLbl.text = section == 0 ? infoItems[0].infoTitle.rawValue : "  Your Custom Categories"
        headerLbl.font = UIFont.systemFont(ofSize: 13)
        headerLbl.textColor = UIColor.white
        headerLbl.textAlignment = NSTextAlignment.center
        headerViw.addSubview(headerLbl)
        
        return headerViw
    }
    
    // MARK: - HomeTableViewCellDelegate
    
    func weightChanged(_ cell: HomeTableViewCell, lbs: Float) {
        let index = cell.tag
        let aCategory = todayInfo.categoryAry[index]
        aCategory.value = lbs
        aCategory.saveLocally()
        todayInfo.saveLocally()
    }
    
    func choiceControlChanged(_ dataItem: InfoItem.Data, mealWeight: MealWeight) {
        todayInfo.setMealValue(dataItem, mealWeight: mealWeight)
        todayInfo.saveLocally()
        totalBtn.setTitle("\(getCyclePoints())", for: UIControlState())
    }
    
    func showInfoForDataItem(_ dataItem: InfoItem.Data) {
        let infoView: InfoViewController = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoView.infoItem = dataItem
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        let valueStr = textField.text! as NSString
        var value = valueStr.floatValue
        let aCategory = todayInfo.categoryAry[index]
        
        value = max(0, min(aCategory.limit, value))
        
        var formattedVal: NSString = ""
        if aCategory.point == 0 {
            formattedVal = String(Int(value)) as NSString
        } else if aCategory.point == 1 {
            formattedVal = String(format: "%.1f", value) as NSString
        } else {
            formattedVal = String(format: "%.2f", value) as NSString
        }
        textField.text = formattedVal as String
        aCategory.value = formattedVal.floatValue
        aCategory.saveLocally()
    }
    
    // MARK: - Private
    
    fileprivate func refreshData() {
        dayLbl.text = "Cycle Day \(Utils.sharedInstance.getCurrDayIndex())"
        todayInfo = Utils.sharedInstance.getCurrDay()
        //        dlog("In refreshData - todayInfo \(todayInfo)")
        tableViw.reloadData()
        totalBtn.setTitle("\(getCyclePoints())", for: UIControlState())
        var indicator: String
        if Utils.sharedInstance.isPreviousDay {
            indicator = "Yesterday"
            cycleIndicatorLbl.textColor = UIColor.red
        } else {
            indicator = "Current"
            cycleIndicatorLbl.textColor = UIColor.white
        }
        cycleIndicatorLbl.text = indicator + " 2-Day Cycle Choice Points (tap for details):"
        lblMessage.text = Utils.sharedInstance.scrollingMessage
    }
}
