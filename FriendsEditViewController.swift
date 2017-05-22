//
//  FriendsEditViewController.swift
//  DietWZLite
//
//  Created by MacBook Air on 5/22/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import MessageUI

class FriendsEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate, UISearchBarDelegate  {
    
    // is the screen in edit mode or create mode
    var editingMode: Bool = false
    var isAdmin: Bool = false
    var isNewUserJoiningMode: Bool = false
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLeaveGroup: UIButton!
    
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnInvite: UIButton!
    
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var segActivePending: UISegmentedControl!
    
    @IBOutlet weak var switchChoicePoints: UISwitch!
    @IBOutlet weak var switchCyclePoints: UISwitch!
    @IBOutlet weak var switchWeight: UISwitch!
    
    @IBOutlet weak var viewFriendList: UIView!
    @IBOutlet weak var viewPref: UIView!
    
    @IBOutlet weak var tblFriends: UITableView!
    
    var searchActive = false
    var searchText   = ""
    
    let deleteButtonColor = UIColor(red: 1, green: 0.2, blue: 0.143, alpha: 1.000)
    let inviteButtonColor = UIColor(red: 0.05, green: 0.57, blue: 0.64, alpha: 1.000)
    
    var currentParseUser = Utils.sharedInstance.userInfo.parseUser
    var currentParseUserProfile = Utils.sharedInstance.userInfo.userProfile
    var userGroupPreference = UserGroupPreference()
    var friendGroup = FriendGroup()
    var friendList = [String]()
    var invitedFriendList = [String]()
    var filteredFriendList = [String]()
    var removeUserIndexPath: IndexPath? = nil
    
    // MARK: - View Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        setupColors()
        lblTitle.text = "Create"
        btnJoin.isHidden = true
        
        switchChoicePoints.isOn = userGroupPreference.shareDailyPoints
        switchCyclePoints.isOn = userGroupPreference.shareCyclePoints
        switchWeight.isOn = userGroupPreference.shareWeightPoints
        
        if !isAdmin {
            btnInvite.isHidden = true
            txtGroupName.isEnabled = false
            txtGroupName.backgroundColor = UIColor.darkGray
            txtGroupName.textColor = ThemeColors.Teal //UIColor.cyanColor()
            segActivePending.isHidden = true
            
            if isNewUserJoiningMode {
                lblTitle.text = "Join"
                btnJoin.isHidden = false
                btnJoin.setTitle("Join Group", for: UIControlState())
                //                btnJoin.titleLabel?.text = "Join Group"
                viewFriendList.isHidden = true
                btnSave.setTitle("Join", for: UIControlState())
                
                switchChoicePoints.isOn = true
                switchCyclePoints.isOn = true
                switchWeight.isOn = true
            }
        }
        
        
        if editingMode {
            lblTitle.text = "Edit"
            txtGroupName.text = userGroupPreference.groupId.groupName
            friendGroup = userGroupPreference.groupId
            
        } else {
            
            btnLeaveGroup.isHidden = true
            userGroupPreference.groupId = friendGroup
            if isAdmin {
                userGroupPreference.acl = Utils.sharedInstance.getPublicReadUserWriteACL()
                //if he is admin and not in editing mode, it means it is a new group that is being created
                //                btnJoin.titleLabel?.text = "Save"
            }
            
            switchChoicePoints.isOn = true
            switchCyclePoints.isOn = true
            switchWeight.isOn = true
            
            //Until a group name is not given, hide and disable things
            viewFriendList.isHidden = true
            viewPref.isHidden = true
        }
        txtGroupName.delegate = self
        invitedFriendList = friendGroup.invitedUserEmails
        self.reloadActivePendingData()
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "You need an internet connection to Save a group")
            btnJoin.isHidden = true
            btnSave.isHidden = true
            btnInvite.isHidden = true
            btnLeaveGroup.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(FriendsEditViewController.dismissKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        segActivePending.selectedSegmentIndex = 0
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onEditingChanged(_ sender: AnyObject) {
        
        if !editingMode {
            viewPref.isHidden = false
            btnJoin.isHidden = false
        }
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "Cannot save a group without internet connection")
            onBack(sender)
            return
        }
        
        
        if isNewUserJoiningMode {
            onJoin(sender)
            return
        }
        
        if(txtGroupName.text == "") {
            showWarningMessage("Group Name", subTitle: "Group name cannot be empty")
            return
        } else {
            friendGroup.groupName = txtGroupName.text!
        }
        
        setUGPPointsFromSwitches()
        
        if editingMode {
            //then the usergroup preference would already be set
            userGroupPreference.saveInBackground()
            //            userGroupPreference.saveLocally()
            _ = navigationController?.popToRootViewController(animated: true)
            
        } else {
            newGroupSave()
            editingMode = true
            btnJoin.isHidden = true
            lblTitle.text = "Edit"
            viewFriendList.isHidden = false
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
    }
    
    /// On Joining, create UGP, add the UGP to accepted Friend Group and remove the email from invited list.
    @IBAction func onJoin(_ sender: AnyObject) {
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "Cannot Join a group without internet connection")
            onBack(sender)
            return
        }
        
        if isNewUserJoiningMode {
            
            dlog("onJoin ugp is \(userGroupPreference)")
            //            debugUGP()
            //            try! userGroupPreference.fetchIfNeeded()
            
            setUGPPointsFromSwitches()
            userGroupPreference.status = UserGroupStatus.Accepted.rawValue
            userGroupPreference.saveInBackground { (success: Bool, error: Error?) -> Void in
                if success {
                    self.friendGroup.add(self.userGroupPreference, forKey: ParseColumnName.FriendGroup.FriendUserIds.rawValue)
                    self.friendGroup.removeObject(self.currentParseUser!.email! as AnyObject, forKey: ParseColumnName.FriendGroup.InvitedUserEmails)
                    
                    self.friendGroup.saveInBackground( block: { (success1:Bool, error1:Error?) -> Void in
                        if success1 {
                            dlog("Send Notification to reload friends")
                            //TODO: Figure out a way to refresh cache for just this UGP & Groups.
                            Utils.sharedInstance.checkForNewFriendsOrGroups()
                            NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
                        } else {
                            dlog("Found error saving friend group")
                            dlog("\(error1)")
                        }
                    })
                    dlog("Just Saved UGP to cloud and Saving Friend Group now")
                } else {
                    derror("UGP was not saved")
                    derror("\(error)")
                }
            }
            dlog("Reloading friends")
            NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
            _ = navigationController?.popViewController(animated: true)
        } else {
            onSave(sender)
        }
    }
    
    private func debugUGP() {
        dlog("onJoin ugp is \(userGroupPreference)")
        dlog("onJoing group is \(friendGroup)")
        dlog("onJoin UGP PFACL \(userGroupPreference.acl)")
        dlog("onJoin UGP PFACL Read Access \(userGroupPreference.acl?.getReadAccess(for: PFUser.current()!))")
        dlog("onJoin UGP PFACL Write Access \(userGroupPreference.acl?.getWriteAccess(for: PFUser.current()!))")
        dlog("onJoin user is \(PFUser.current())")
    }
    
    @IBAction func onInvite(_ sender: AnyObject) {
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "Cannot Invite a friend without internet connection")
            onBack(sender)
            return
        }
        
        let alertController = UIAlertController(title: "Invite", message: "Enter friend's email address ", preferredStyle: .alert)
        
        let inviteAction = UIAlertAction(title: "Invite", style: .default) { (_) in
            let emailTextField = alertController.textFields![0]
            let email = emailTextField.text!.lowercased()
            //            let passwordTextField = alertController.textFields![1] as! UITextField
            dlog("Invitied \(email)")
            
            self.friendGroup.invite(email)
            //viewwill appear gets called, none of the below takes effect
            
            if MFMailComposeViewController.canSendMail() {
                let picker = MFMailComposeViewController()
                picker.mailComposeDelegate = self
                picker.setToRecipients([email])
                picker.setSubject("Join me using DietWZ")
                picker.setMessageBody("Please join me to work together using DietWZ", isHTML: true)
                self.present(picker, animated: true, completion: nil)
            } else {
                //TODO: Send email from backend
            }
            self.invitedFriendList.append(email)
            self.segActivePending.selectedSegmentIndex = 1
            self.reloadActivePendingData()
        }
        
        inviteAction.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Email"
            textField.keyboardType = UIKeyboardType.emailAddress
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                inviteAction.isEnabled = textField.text != ""
            }
        }
        alertController.addAction(inviteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onLeaveGroup(_ sender: AnyObject) {
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "Cannot Leave a group without internet connection")
            onBack(sender)
            return
        }
        
        self.userGroupPreference.leaveGroup()
        //TODO: Figure out a way refresh cache from local.
        NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
        _ = navigationController?.popToRootViewController(animated: true)
        
    }
    
    /**
     * Toggle between what list is shown under friends
     */
    
    @IBAction func onActivePendingFriends(_ sender: AnyObject) {
        self.reloadActivePendingData()
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        //        switch result {
        //        case MFMailComposeResultCancelled:
        //            dlog("Mail cancelled")
        //        case MFMailComposeResultSaved:
        //            dlog("Mail saved")
        //        case MFMailComposeResultSent:
        //            dlog("Mail sent")
        //        case MFMailComposeResultFailed:
        //            dlog("Mail sent failure: \(error!.localizedDescription)")
        //        default:
        //            break
        //        }
        controller.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    //friend list should only show user name if confirmed
    //if not show email address
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchActive {
            return filteredFriendList.count
        }
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        dlog(">> FriendsEdit - cellForRowAtIndexPath \(indexPath.row)")
        
        let cell   = tableView.dequeueReusableCell(withIdentifier: "FriendEmailCell", for: indexPath)
        var  emailOrUserName = friendList[(indexPath as NSIndexPath).row]
        if self.searchActive {
            emailOrUserName = filteredFriendList[(indexPath as NSIndexPath).row]
        }
        cell.textLabel?.text = emailOrUserName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        
        if !isAdmin {
            return []
        }
        
        var  emailOrUserName = friendList[(indexPath as NSIndexPath).row]
        if self.searchActive {
            emailOrUserName = filteredFriendList[(indexPath as NSIndexPath).row]
        }
        
        var title = "Remove"
        var menuTitle = "Remove User"
        var menuMessage = "Are you sure you want to permanently remove \(emailOrUserName)?"
        var cancelButtonLabel = "Cancel"
        if segActivePending.selectedSegmentIndex == 1 {
            title = "Cancel"
            menuTitle = "Cancel Invitation"
            menuMessage = "Are you sure you want to cancel the invite \(emailOrUserName)?"
            cancelButtonLabel = "Don't Cancel"
        }
        
        let removeAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: title , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
            
            self.removeUserIndexPath = indexPath
            
            let leaveMenu = UIAlertController(title: menuTitle, message: menuMessage, preferredStyle: .actionSheet)
            
            let removeUserAction = UIAlertAction(title: menuTitle, style: UIAlertActionStyle.destructive, handler: self.removeUser)
            let cancelAction = UIAlertAction(title: cancelButtonLabel, style: UIAlertActionStyle.cancel, handler: self.cancelRemoveUser)
            
            leaveMenu.addAction(removeUserAction)
            leaveMenu.addAction(cancelAction)
            
            self.present(leaveMenu, animated: true, completion: nil)
        })
        
        return [removeAction]
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtGroupName.resignFirstResponder()
        self.view.endEditing(true)
        return true
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
        self.populateFilteredFriendList()
        self.tblFriends.reloadData()
    }
    
    // MARK: - Private
    
    fileprivate func setUGPPointsFromSwitches() {
        userGroupPreference.shareCyclePoints = switchCyclePoints.isOn
        userGroupPreference.shareDailyPoints = switchChoicePoints.isOn
        userGroupPreference.shareWeightPoints = switchWeight.isOn
    }
    
    /// Reload Active Friends or Pending Email Addresses.
    fileprivate func reloadActivePendingData() {
        if segActivePending.selectedSegmentIndex == 1 {
            friendList = self.invitedFriendList
        } else  {
            friendList = friendGroup.getActiveFriendList()
        }
        populateFilteredFriendList()
        tblFriends.reloadData()
    }
    
    fileprivate func removeUser(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = removeUserIndexPath {
            tblFriends.beginUpdates()
            friendList.remove(at: (indexPath as NSIndexPath).row)
            self.populateFilteredFriendList()
            if segActivePending.selectedSegmentIndex == 0 {
                dlog("Removing User")
                friendGroup.removeUser((indexPath as NSIndexPath).row)
            } else {
                dlog("Cancelling the invite")
                friendGroup.cancelInvite((indexPath as NSIndexPath).row)
            }
            tblFriends.deleteRows(at: [indexPath], with: .automatic)
            tblFriends.endUpdates()
        }
        
    }
    
    fileprivate func cancelRemoveUser(_ alertAction: UIAlertAction!) {
        removeUserIndexPath = nil
    }
    
    fileprivate func populateFilteredFriendList() {
        self.searchActive = !self.searchText.isEmpty
        if searchText.isEmpty {
            return
        }
        filteredFriendList = friendList.filter({ (friend) -> Bool in
            let tmp: NSString = friend as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
    }
    
    /**
     Setup the colors of the buttons and UI controls that can't be done thru IB
     */
    fileprivate func setupColors() {
        btnJoin.layer.cornerRadius = 10
        btnJoin.layer.borderWidth = 1
        btnJoin.layer.borderColor = ThemeColors.Teal.cgColor //UIColor.cyanColor().CGColor
        btnJoin.backgroundColor = UIColor.clear
        btnJoin.setTitleColor(ThemeColors.Teal, for: UIControlState())
        
        btnLeaveGroup.layer.borderColor = deleteButtonColor.cgColor
        btnLeaveGroup.layer.cornerRadius = 5
        btnLeaveGroup.layer.borderWidth = 1
        btnLeaveGroup.layer.borderColor = deleteButtonColor.cgColor
        btnLeaveGroup.backgroundColor = UIColor.clear
        btnLeaveGroup.setTitleColor(deleteButtonColor, for: UIControlState())
        
        btnInvite.layer.borderColor = UIColor.green.cgColor
        btnInvite.layer.cornerRadius = 5
        btnInvite.layer.borderWidth = 1
        btnInvite.layer.borderColor = UIColor.green.cgColor
        btnInvite.backgroundColor = UIColor.clear
        btnInvite.setTitleColor(UIColor.green, for: UIControlState())
    }
    
    fileprivate func newGroupSave() {
        
        if !IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.showNoInternetDialog(msg: "Cannot save a group without internet connection")
            return
        }
        
        // for a new user group
        friendGroup.admin = Utils.sharedInstance.userInfo.userProfile
        friendGroup.userName = Utils.sharedInstance.userInfo.username
        friendGroup.acl = Utils.sharedInstance.getPublicReadWriteACL()
        
        userGroupPreference.status = UserGroupStatus.Accepted.rawValue
        userGroupPreference.userProfile = currentParseUserProfile
        userGroupPreference.userName = Utils.sharedInstance.userInfo.username
        userGroupPreference.groupId = friendGroup
        userGroupPreference.acl = Utils.sharedInstance.getPublicReadUserWriteACL()
        
        Utils.sharedInstance.userGroupPreferences.append(userGroupPreference)
        userGroupPreference.saveInBackground(block: { (success1: Bool, error1: Error?) -> Void in
            if success1 {
                self.currentParseUserProfile.addUniqueObject(self.userGroupPreference, forKey: ParseColumnName.User.UGP.rawValue)
                self.currentParseUserProfile.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                    if success {
                        self.friendGroup.addUniqueObject(self.userGroupPreference, forKey: ParseColumnName.FriendGroup.FriendUserIds)
                        self.friendGroup.saveInBackground(block: { (success: Bool, error: Error?) -> Void in
                            if success {
                                self.reloadActivePendingData()
                                //TODO: Figure out a way to refresh cache for just this UGP & Groups, so that app would seem faster and save an api call
                                Utils.sharedInstance.checkForNewFriendsOrGroups()
                                NotificationCenter.default.post(name: Notification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_FRIENDS_LOADED), object: nil)
                            }
                        })
                    }
                })
            }
        })
    }
}
