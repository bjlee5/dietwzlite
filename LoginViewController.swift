//
//  LoginViewController.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 23/10/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailFld: UITextField!
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var keepBtn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnTestThings: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.attributedText = Utils.sharedInstance.getDietWzTitleString(2)
        emailFld.autocorrectionType = .no
        emailFld.autocapitalizationType = .none
        emailFld.spellCheckingType = .no
        
        passwordFld.autocorrectionType = .no
        passwordFld.autocapitalizationType = .none
        passwordFld.spellCheckingType = .no
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.applicationActivated(_:)), name: NSNotification.Name(rawValue: Utils.sharedInstance.NOTIFICATION_APPLICATION_ACTIVATED), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        btnSignIn.setTitle("Sign In", forState: .Normal)
        btnSignIn.setTitle("Logging In ...", for: .highlighted)
        btnSignIn.setTitleColor(UIColor.white, for: .highlighted)
        
        btnTestThings.isHidden = true
        self.perform(#selector(LoginViewController.checkIfLoginIsNecessary), with: nil, afterDelay: 0.0)
        
        
//        _ = PFUser.query()!
//        userQuery.includeKey("userGroupPreferences")
//        userQuery.includeKey("userGroupPreferences.groupId")
//        userQuery.includeKey("userGroupPreferences.groupId.friendUserIds")
//        userQuery.includeKey("userGroupPreferences.groupId.friendUserIds.user")
//        dlog("Hacked code!!!!!!!!!")
//        dlog("\(try! userQuery.findObjects())")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func btnTestAction(_ sender: AnyObject) {
    }
    
    
    func applicationActivated(_ notification: Notification?) {
        self.perform(#selector(LoginViewController.checkIfLoginIsNecessary), with: nil, afterDelay: 0.0)
    }
    
    func checkIfLoginIsNecessary() {
        keepBtn.isSelected = true
        
        let userInfo = Utils.sharedInstance.userInfo
        
        //if keepLogged is checked a
        dlog("Login keepLogged:\(userInfo.keepLogged) & logged:\(userInfo.logged) userprofile=\(userInfo.userProfile)")
        
        if userInfo.keepLogged  && userInfo.logged {
//            try! userInfo.userProfile.fetchIfNeeded()
            try! userInfo.userProfile.fetchFromLocalDatastore()
            
            performSegue(withIdentifier: "signin", sender: nil)
            dlog("<<<<<<<<<<<<< appInitialize again?? <<<<<<")
            Utils.sharedInstance.appInitialize()
        } else {
            emailFld.text = userInfo.username
            passwordFld.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        print("3. shouldPerformSegueWithIdentifier - currentUser  \(PFUser.current()) ")
        
        if identifier == "signin" {
//            btnSignIn.titleLabel?.text = "Logging you in ..."
            if emailFld.text!.isEmpty {
//                let alert = UIAlertView(title: "", message: msg_please_enter_email, delegate: nil, cancelButtonTitle: "OK")
//                alert.show()
                showWarningMessage("User Name", subTitle: msg_please_enter_email)
//                showMessage(msg_please_enter_email, self)
//                btnSignIn.titleLabel?.text = "Sign In"
                return false
            }
//            passwordFld.text = emailFld.text
            if passwordFld.text!.isEmpty {
//                let alert = UIAlertView(title: "", message: msg_please_enter_password, delegate: nil, cancelButtonTitle: "OK")
//                alert.show()
                showWarningMessage("Password", subTitle: msg_please_enter_password)
//                showMessage(msg_please_enter_password, self)
//                btnSignIn.titleLabel?.text = "Sign In"
                return false
            }
            
            
//            EZLoadingActivity.show("Logging In...", disableUI: true)
            let userInfo = Utils.sharedInstance.userInfo
            if IJReachability.isConnectedToNetwork() {
//                EZLoadingActivity.hide()
                userInfo.login((emailFld.text?.lowercased())!, password: passwordFld.text!)
            } else {
//                let alert = UIAlertView(title: "No Network", message: msg_no_internet_at_login, delegate: nil, cancelButtonTitle: "OK")
//                alert.show()
                showWarningMessage("No Network", subTitle: msg_no_internet_at_login)
                return false
            }
            
            print("4. shouldPerformSegueWithIdentifier - currentUser  \(PFUser.current()) ")
            
            if (!userInfo.logged) {
//                EZLoadingActivity.hide()
//                let alert = UIAlertView(title: "", message: msg_user_not_logged_in, delegate: nil, cancelButtonTitle: "Ok")
//                alert.show()
                showWarningMessage("Login failed", subTitle: msg_user_not_logged_in)
//                showMessage(msg_user_not_logged_in, self)
//                btnSignIn.titleLabel?.text = "Sign In"
                return false
            } else {
//                EZLoadingActivity.hide()
//                EZLoadingActivity.hide(success: true, animated: false)
                if(userInfo.keepLogged != keepBtn.isSelected) {
                    userInfo.keepLogged = keepBtn.isSelected
                    userInfo.save()
                }
            }
        }
//        btnSignIn.titleLabel?.text = "Sign In"
        return true
    }
    
       
    @IBAction func onKeep(_ sender: AnyObject) {
        keepBtn.isSelected = !keepBtn.isSelected
    }

    @IBAction func onCantAccess(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: DIETWZ_URL.ForgotPassword)!)
//        UIApplication.shared.openURL(URL(string: "https://mbz-stage-meteor2.herokuapp.com/forgotPassword")!)
    }

}

