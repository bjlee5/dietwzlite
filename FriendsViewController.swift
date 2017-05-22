//
//  FriendsDetailViewController.swift
//  DietWZLite
//
//  Created by MacBook Air on 5/22/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tblFriendGroup: UITableView!
    @IBOutlet weak var segActivePending: UISegmentedControl!
    
    @IBOutlet weak var searchGroups: UISearchBar!
    @IBOutlet weak var btnBack: UIButton!
    
    var userGroupPreferences = Utils.sharedInstance.userGroupPreferences
    var groupList: [UserGroupPreference] = []
    var filteredGroupList: [UserGroupPreference] = []
    
    var leaveGroupIndexPath: IndexPath? = nil
    var fromAnotherView: Bool = false
    var searchActive : Bool = false
    var searchText = ""
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(FriendsViewController.friendsLoaded(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(FriendsViewController.dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        //        btnBack.hidden = !fromAnotherView
        userGroupPreferences = Utils.sharedInstance.userGroupPreferences
        self.loadGroupList()
        tblFriendGroup.allowsMultipleSelection = false
        dlog("Friend Group count \(userGroupPreferences.count) " )
        tblFriendGroup.estimatedRowHeight = 50
        tblFriendGroup.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        segActivePending.selectedSegmentIndex = 0
        loadGroupList()
        tblFriendGroup.reloadData()
        hidesBottomBarWhenPushed = false
        if IJReachability.isConnectedToNetwork() {
            btnAdd.isEnabled = true
        } else {
            Utils.sharedInstance.showNoInternetDialog(msg: "You need an internet connection to Add a group")
            btnAdd.isEnabled = false
        }
        
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAddGroup(_ sender: AnyObject) {
        let nextCtlr: FriendsEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "FriendsEditViewController") as! FriendsEditViewController
        nextCtlr.isAdmin = true
        nextCtlr.editingMode = false
        self.navigationController?.pushViewController(nextCtlr, animated: true)
    }
    
    @IBAction func onInfo(_ sender: UIButton) {
        
        let infoView = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        infoView.infoItem = InfoItem.Data.Friends
        navigationController?.pushViewController(infoView, animated: true)
    }
    
    @IBAction func onActivePending(_ sender: AnyObject) {
        loadGroupList()
        tblFriendGroup.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        dlog("FriendsVC - numberOfRowsInSection")
        if searchActive {
            return filteredGroupList.count
        }
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        dlog(">> FriendsVC - cellForRowAtIndexPath \(indexPath.row)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendGroupCell", for: indexPath)
        let userGroupPref = searchActive ? filteredGroupList[(indexPath as NSIndexPath).row] : groupList[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = userGroupPref.groupId.groupName
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        dlog("FriendsVC - didSelectRowAtIndexPath \(indexPath.row)")
        
        let ugp = groupList[(indexPath as NSIndexPath).row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if ugp.status == UserGroupStatus.Invited.rawValue {
            
            let nextCtlr = self.storyboard?.instantiateViewController(withIdentifier: "FriendsEditViewController") as! FriendsEditViewController
            nextCtlr.userGroupPreference = ugp
            nextCtlr.isAdmin = false
            nextCtlr.isNewUserJoiningMode = true
            nextCtlr.editingMode = true
            self.navigationController?.pushViewController(nextCtlr, animated: true)
            
        } else {
            let nextCtlr = self.storyboard?.instantiateViewController(withIdentifier: "FriendsDetailViewController") as! FriendsDetailViewController
            nextCtlr.setUGP(ugp)
            self.navigationController?.pushViewController(nextCtlr, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        
        //        dlog("FriendsVC - editActionsForRowAtIndexPath \(indexPath.row)")
        //        // 1
        //        var inviteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Invite" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
        //            // 2
        //            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
        //
        //            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
        //            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        //
        //            shareMenu.addAction(twitterAction)
        //            shareMenu.addAction(cancelAction)
        //
        //
        //            self.presentViewController(shareMenu, animated: true, completion: nil)
        //        })
        
        // 3
        let leaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Leave" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            // 4
            let groupName = self.groupList[(indexPath as NSIndexPath).row].groupId.groupName
            self.leaveGroupIndexPath = indexPath
            
            let leaveMenu = UIAlertController(title: "Leave Group", message: "Are you sure you want to permanently leave \(groupName)?", preferredStyle: .actionSheet)
            
            let LeaveGroupAction = UIAlertAction(title: "Leave", style: UIAlertActionStyle.destructive, handler: self.handleLeaveGroup)
            let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: self.handleCancelLeaveGroup)
            
            leaveMenu.addAction(LeaveGroupAction)
            leaveMenu.addAction(CancelAction)
            
            self.present(leaveMenu, animated: true, completion: nil)
        })
        return [leaveAction]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            leaveGroupIndexPath = indexPath
            let groupName = groupList[(indexPath as NSIndexPath).row].groupId.groupName
            confirmLeaveGroup(groupName)
        }
    }
    
    // MARK: - Utility
    
    /// Load the group list based on various parameters (either search filter or segment choice)
    func loadGroupList() {
        groupList = getGroups(segActivePending.selectedSegmentIndex == 0 ? .Accepted : .Invited)
        populateFilteredGroupList()
    }
    
    func confirmLeaveGroup(_ groupName: String) {
        let alert = UIAlertController(title: "Leave Group", message: "Are you sure you want to permanently leave \(groupName)?", preferredStyle: .actionSheet)
        
        let LeaveGroupAction = UIAlertAction(title: "Leave", style: .destructive, handler: handleLeaveGroup)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: handleCancelLeaveGroup)
        
        alert.addAction(LeaveGroupAction)
        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLeaveGroup(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = leaveGroupIndexPath {
            tblFriendGroup.beginUpdates()
            //is it ugp or grouplist?
            dlog("ugp BEFORE remove \(userGroupPreferences.count)")
            let ugpRemoved: UserGroupPreference = userGroupPreferences.remove(at: (indexPath as NSIndexPath).row)
            self.populateFilteredGroupList()
            ugpRemoved.leaveGroup()
            dlog("ugp AFTER remove \(userGroupPreferences.count)")
            loadGroupList()
            tblFriendGroup.deleteRows(at: [indexPath], with: .automatic)
            tblFriendGroup.endUpdates()
        }
    }
    
    func handleCancelLeaveGroup(_ alertAction: UIAlertAction!) {
        leaveGroupIndexPath = nil
    }
    
    //handle when new friends data is loaded
    func friendsLoaded(_ notification: Notification?) {
        userGroupPreferences = Utils.sharedInstance.userGroupPreferences
        loadGroupList()
        tblFriendGroup.reloadData()
    }
    
    // MARK: - UISearchBarDelegate
    
    func dismissKeyBoard() {
        view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        dismissKeyBoard()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        dismissKeyBoard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        dismissKeyBoard()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.populateFilteredGroupList()
        self.tblFriendGroup.reloadData()
    }
    
    // MARK: - Private
    
    /// return the list of user group preference based on string passed ("accepted"/"invited")
    fileprivate func getGroups(_ status: UserGroupStatus) -> [UserGroupPreference] {
        
        var activeUGP = [UserGroupPreference]()
        userGroupPreferences.filter{ $0.status == status.rawValue }.forEach{ activeUGP.append($0) }
        return activeUGP
    }
    
    fileprivate func populateFilteredGroupList() {
        self.searchActive = !self.searchText.isEmpty
        if searchText.isEmpty {
            return
        }
        filteredGroupList = groupList.filter({ (ugp) -> Bool in
            let tmp: NSString = ugp.groupId.groupName as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
    }
}
