//
//  CategoriesViewController.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 5/1/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tblCategories: UITableView!
    
    fileprivate var customCategories = Utils.sharedInstance.categoryAry.filter() {$0.userDefined}

    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dlog("Custom categories count \(customCategories.count) " )
        hidesBottomBarWhenPushed = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        customCategories = Utils.sharedInstance.categoryAry.filter() {$0.userDefined}
        btnAdd.isEnabled = customCategories.count < Utils.sharedInstance.CUSTOM_COUNT
        tblCategories.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath)
        
        let catInfo = customCategories[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = catInfo.label
        
        if [.counter, .question, .numeric].contains(catInfo.mode) {
            cell.imageView?.image = UIImage(named: catInfo.mode.stringValue)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let nextCtlr: CategoriesDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesDetailViewController") as! CategoriesDetailViewController
        nextCtlr.oldCategoryObject = customCategories[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(nextCtlr, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let cat = customCategories.remove(at: (indexPath as NSIndexPath).row)
        Utils.sharedInstance.removeCategoryFromArray(cat)
        btnAdd.isEnabled = customCategories.count < Utils.sharedInstance.CUSTOM_COUNT
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
}
