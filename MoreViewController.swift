//
//  MoreViewController.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 27/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit
import SCLAlertView

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet weak var btnLogout: UIButton!
//    var infoItems = [InfoItem(infoTitle: .EditAccount), InfoItem(infoTitle: .EditDataAndPreferences), InfoItem(infoTitle: .Reset), InfoItem(infoTitle: .ChangeDayInCycle)]
    var infoItems = [InfoItem(infoTitle: .EditAccount), InfoItem(infoTitle: .EditDataAndPreferences), InfoItem(infoTitle: .Reset)]

    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.changeCycleButtonTitle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabItem = tabBarController.selectedIndex
        if tabItem == 1 || tabItem == 3 {
            _ = navigationController?.popToRootViewController(animated: false)
        }
    }

    // MARK: - Actions
    
    //The logout buttton is now reused as Change Cycle button
    @IBAction func onLogout(_ sender: AnyObject?) {
        if Utils.sharedInstance.isPreviousDay {
            Utils.sharedInstance.isPreviousDay = false
        } else if Utils.sharedInstance.dailyHistory.count > 1 {
            Utils.sharedInstance.isPreviousDay = true
        }
//        self.changeCycleButtonTitle()
        self.tabBarController?.selectedIndex = 0
    }
    
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return infoItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoItems[section].dataItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let infoItem = infoItems[(indexPath as NSIndexPath).section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell") as! MoreTableViewCell
        cell.configureWithTableItem(infoItem, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerViw = UIView()
        headerViw.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30)
        headerViw.backgroundColor = UIColor.darkGray
        
        let headerLbl: UILabel = UILabel()
        headerLbl.frame = headerViw.bounds
        headerLbl.text = "  " + infoItems[section].infoTitle.rawValue
        headerLbl.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        headerLbl.adjustsFontSizeToFitWidth = true
        headerLbl.textColor = ThemeColors.Teal
        headerLbl.textAlignment = NSTextAlignment.center

        headerViw.addSubview(headerLbl)
        return headerViw
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataItem = infoItems[(indexPath as NSIndexPath).section].dataItems()[(indexPath as NSIndexPath).row].data
        let infoTitle = infoItems[(indexPath as NSIndexPath).section].infoTitle
        
        switch infoTitle {
        case .EditAccount:
            editAccount(dataItem)
        case .EditDataAndPreferences:
            editDataAndPreferences(dataItem)
        case .ChangeDayInCycle:
            changeDayInCycle(dataItem)
            tableView.reloadSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .automatic)
        case .Reset:
            reset(dataItem)
        default:
            assertionFailure("condition not accounted for \(infoTitle)")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private

    fileprivate func logout() {
        
        let resetAlert = SCLAlertView()
        let subTitle = "You'll need Internet connection to log back in. Do you still want to Logout?"
        let title = "Logout?"
        resetAlert.addButton("Yes") {
            Utils.sharedInstance.userInfo.logout()
            self.tabBarController?.dismiss(animated: true, completion: nil)
        }
        resetAlert.showWarning(title, subTitle: subTitle, closeButtonTitle: "Cancel", timeout: nil, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
        
    }
    
    fileprivate func showChangePasswordDialog() {
        let nextCtlr: ChangePasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "changePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(nextCtlr, animated: true)
    }
    
    fileprivate func editAccount(_ item: InfoItem.Data) {
        switch item {
        case .ChangePassword:
            showChangePasswordDialog()
        case .ResetPassword:
            logoutBeforeOpenURL()
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ForgotPassword)!)
        case .ChangeUserName:
            logoutBeforeOpenURL()
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ModifyUserName)!)
        case .ChangeEmail:
            logoutBeforeOpenURL()
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ModifyEmail)!)
        case .Logout:
            logout()
        default:
            assertionFailure("Case \(item) not accounted for")
        }
    }
    
    fileprivate func logoutBeforeOpenURL() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
        //logout only if there is network
        
        if IJReachability.isConnectedToNetwork() {
            Utils.sharedInstance.userInfo.keepLogged = false
            Utils.sharedInstance.userInfo.logged = false
            Utils.sharedInstance.userInfo.updateFromHandHeld = true
        }
    }
    
    fileprivate func editDataAndPreferences(_ item: InfoItem.Data) {
        switch item {
            
        case .ShowEmailUserName:
            showEmailandUserNameDialog()
        case .EditPersonalData:
            changePersonalData()
        case .ChangePassword:
            showChangePasswordDialog()
        case .ResetPassword:
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ForgotPassword)!)
            
//            let infoView = storyboard?.instantiateViewControllerWithIdentifier("InfoViewController") as! InfoViewController
//            infoView.infoItem = .CustomCategory
//            navigationController?.pushViewController(infoView, animated: true)
            
        case .AddDeleteOptionalCategoryTracking: // Custom Category
            let nextCtlr: CategoriesViewController = self.storyboard?.instantiateViewController(withIdentifier: "CategoriesController") as! CategoriesViewController
            self.navigationController?.pushViewController(nextCtlr, animated: true)
        case .ChangeUserName:
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ModifyUserName)!)
        case .ChangeEmail:
            UIApplication.shared.openURL(URL(string: DIETWZ_URL.ModifyEmail)!)
        default:
            assertionFailure("Case \(item) not accounted for")
        }
    }
    
    fileprivate func changeDayInCycle(_ item: InfoItem.Data) {
        switch item {
        case .GoBackOneDay:
            if !Utils.sharedInstance.isPreviousDay && Utils.sharedInstance.dailyHistory.count > 1 {
                Utils.sharedInstance.isPreviousDay = true
            }
        case .ReturnToCurrentDay:
            if Utils.sharedInstance.isPreviousDay {
                Utils.sharedInstance.isPreviousDay = false
            }
        default:
            assertionFailure("Case \(item) not accounted for")
        }
        
        self.tabBarController?.selectedIndex = 0
    }
    
    
    fileprivate func changeCycleButtonTitle() {
        
        if Utils.sharedInstance.dailyHistory.count < 2 {
            btnLogout.isHidden = true
        } else {
            if Utils.sharedInstance.isPreviousDay {
                btnLogout.setTitle("Return to Today", for: UIControlState())
            } else {
                btnLogout.setTitle("Finish Yesterday's Entries", for: UIControlState())
            }
        }
    }
    
    fileprivate func changePersonalData() {
        
        let nextCtlr: RegisterViewController = self.storyboard?.instantiateViewController(withIdentifier: "registerViewController") as! RegisterViewController
        nextCtlr.isEditingMode = true
        self.navigationController?.pushViewController(nextCtlr, animated: true)

//        let personalDataAlert = SCLAlertView()
//        personalDataAlert.addTextField("Change Age")
//        personalDataAlert.addTextField("Male/Female")
//        
//        personalDataAlert.addButton("Save") {
//            showSuccessNotification("Personal Data Saved Successfully")
//        }
//        
//        personalDataAlert.showEdit("Change Personal Data", subTitle: "", closeButtonTitle: "Cancel", duration: 0.0, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.whiteColor().toHexString(), circleIconImage: nil)
        
    }
    
    fileprivate func showEmailandUserNameDialog() {
        let personalDataAlert = SCLAlertView()
        let userName = Utils.sharedInstance.userInfo.username
        let userEmail = Utils.sharedInstance.userInfo.email
        let subTitle = "Username: \(userName) \nEmail: \(userEmail)"
//        personalDataAlert.showInfo("Personal Info", subTitle: subTitle)
        personalDataAlert.showInfo("Personal Info", subTitle: subTitle, closeButtonTitle: "OK", timeout: nil, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
    }
    
    
    fileprivate func reset(_ item: InfoItem.Data) {
        
        let resetAlert = SCLAlertView()
        var subTitle = ""
        var title = "Reset Current Cycle"
        
        switch item {
        case .ResetCurrentCycle:
            subTitle = "The data of the current cycle will be deleted. Are you sure?"
            resetAlert.addButton("Yes") {
                Utils.sharedInstance.resetCurrCycle()
                self.tabBarController?.selectedIndex = 0
            }
        case .ResetCurrentDay:
            title = "Reset Current Day"
            subTitle = "The data of the current day will be deleted. Are you sure?"
            resetAlert.addButton("Yes") {
                Utils.sharedInstance.resetCurrDay()
                self.tabBarController?.selectedIndex = 0
            }
        default:
            assertionFailure("Case \(item) not accounted for")
        }
        
        resetAlert.showWarning(title, subTitle: subTitle, closeButtonTitle: "Cancel", timeout: nil, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
    }
}
