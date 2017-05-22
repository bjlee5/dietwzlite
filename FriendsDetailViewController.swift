//
//  FriendsDetailViewController.swift
//  DietWZLite
//
//  Created by MacBook Air on 5/22/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit


class FriendsDetailViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var tblGraph: UITableView!
    @IBOutlet weak var tblNews: UITableView!
    @IBOutlet weak var lblGroupName: UILabel!
    
    fileprivate var friendsUGP = [UserGroupPreference]()
    fileprivate var friendsNewsUGP = [UserGroupPreference]()
    var userGroupPreference = UserGroupPreference()
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer!.delegate = nil
        self.lblGroupName.text = self.userGroupPreference.groupId.groupName
        graphView.layer.cornerRadius = 3.0
        graphView.layer.masksToBounds = false
        
        graphView.layer.shadowColor = UIColor.white.withAlphaComponent(0.2).cgColor
        graphView.layer.shadowOffset = CGSize(width: 0, height: 3)
        graphView.layer.shadowOpacity = 0.8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblNews.reloadData()
        tblGraph.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEditGroup(_ sender: AnyObject) {
        let nextCtlr = self.storyboard?.instantiateViewController(withIdentifier: "FriendsEditViewController") as! FriendsEditViewController
        nextCtlr.isAdmin = self.userGroupPreference.isAdmin()
        nextCtlr.editingMode = true
        nextCtlr.userGroupPreference = self.userGroupPreference
        self.navigationController?.pushViewController(nextCtlr, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsUGP.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblGraph {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "FriendLeaguePointCell",for: indexPath) as! FriendLeaguePointCell
            cell.setUserGroupPreference(self.friendsUGP[(indexPath as NSIndexPath).row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsStoryCell",for: indexPath) as! NewsStoryCell
            cell.setUserGroupPreference(self.friendsNewsUGP[(indexPath as NSIndexPath).row])
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Utility
    
    func setUGP(_ ugp: UserGroupPreference)  {
        self.userGroupPreference = ugp
        self.friendsUGP = ugp.friendsUGP
        self.friendsNewsUGP = ugp.friendsNewsUGP
    }
}
