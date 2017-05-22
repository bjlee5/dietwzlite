//
//  SearchViewController.swift
//  Moblzip
//
//  Created by Niklas Olsson on 25/12/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit
import ADBIndexedTableView

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, ADBIndexedTableViewDataSource {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBannerAd: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indexTableViw: ADBIndexedTableView!
    
    var dataAry = [HealthyAlternatives]()
    
    var kName = "itemDescrip"
    var itemHACategory = "All"
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblBannerAd.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        
        lblBannerAd.text = "\(itemHACategory) \n\(lblBannerAd.text!)"
        lblTitle.text = "Search \(itemHACategory != "All" ? "\(itemHACategory)s" : itemHACategory) Database"
        
        dataAry = HealthyAlternatives.loadAllForTableView1(itemHACategory)
        kName = "itemDescrip"
        
        if searchBar.text == "" {
           reloadTableData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions

    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
        reloadTableData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            
            let revisedAry = dataAry.filter {
                let haObjDesc = $0[self.kName] as? String
                let haKeyWords = $0["itemKeywords"] as? String
                return haObjDesc!.range(of: searchText, options: .caseInsensitive) != nil || haKeyWords!.range(of: searchText, options: .caseInsensitive) != nil
            }
            
            indexTableViw.reloadData(with: revisedAry)
        
        } else {
            reloadTableData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    // MARK: - ADBIndexedTableViewDataSource
    
    func objectsField(for tableView: ADBIndexedTableView!) -> String! {
        return kName
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for :indexPath)
        let dataItem = indexTableViw.object(at: indexPath) as! PFObject
        cell.textLabel?.text = dataItem[kName] as? String
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailsVC = storyboard?.instantiateViewController(withIdentifier: "DetailDataViewController") as! DetailDataViewController
        detailsVC.dataInfo = indexTableViw.object(at: indexPath) as! HealthyAlternatives
        navigationController?.pushViewController(detailsVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private
    
    /// reload table data from correct data source based on what screen is being shown
    fileprivate func reloadTableData() {
        indexTableViw.reloadData(with: dataAry)
    }
}
