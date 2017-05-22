//
//  InfoTableViewController.swift
//  Moblzip
//
//  Created by Niklas Olsson on 27/11/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit
import Async

enum DisplayMode {
    case appInfo
    case hadbSearch
}

class InfoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var infoTbl: UITableView!
    @IBOutlet weak var lblDisclaimer: UILabel!
    @IBOutlet weak var backButton: UIButton!

    var displayMode = DisplayMode.appInfo
    
    var searchHADBArray = HealthyAlternatives.loadAllHealthyAlternativeCategories()
    
    lazy var infoItems: [InfoItem] = {
        return self.displayMode == .appInfo ? [InfoItem(infoTitle: .HealthyAlternativesAndAdvice), InfoItem(infoTitle: .RestaurantTips)] : [InfoItem(infoTitle: .HealthyAlternativesDatabase)]
    }()
    
    // MARK: - View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if displayMode == .appInfo {
            
            Async.userInteractive {
                HealthyAlternatives.cacheHADB()
            }
            
            backButton.isHidden = true
            
        } else {
            lblDisclaimer.text = fair_use_disclaimer
            
            backButton.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dayLbl.text = "Cycle Day \(Utils.sharedInstance.getCurrDayIndex())"
        infoTbl.contentOffset = CGPoint.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return infoItems.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return infoItems[section].infoTitle.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayMode == .appInfo ? infoItems[section].dataItems().count : searchHADBArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var itemTitle: String!
        if displayMode == .appInfo {
            itemTitle = infoItems[(indexPath as NSIndexPath).section].dataItems()[(indexPath as NSIndexPath).row].data.rawValue
        } else {
            itemTitle = "Search \(searchHADBArray![(indexPath as NSIndexPath).row])" + (searchHADBArray![(indexPath as NSIndexPath).row] != "All" ? "s" : "")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        cell.textLabel?.text = itemTitle
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.textAlignment = .right
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 16)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var controller: UIViewController!
        
        if displayMode == .hadbSearch {
            
            controller = storyboard?.instantiateViewController(withIdentifier: "SearchController")
            (controller as! SearchViewController).itemHACategory = (searchHADBArray?[(indexPath as NSIndexPath).row])!
            
        } else if IndexPath(row: 0, section: 0) == indexPath {
            
            controller = storyboard?.instantiateViewController(withIdentifier: "InfoTableViewController")
            (controller as! InfoTableViewController).displayMode = .hadbSearch
            
        } else {
            
            controller = storyboard?.instantiateViewController(withIdentifier: "InfoViewController")
            (controller as! InfoViewController).infoItem = infoItems[(indexPath as NSIndexPath).section].dataItems()[(indexPath as NSIndexPath).row].data
        }
        
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
