//
//  ChangePasswordViewController.swift
//  Moblzip
//
//  Created by Sujit Maharana on 3/20/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import UIKit
import Async

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtOldPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnChangePassword: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    var editingOldPassword  = false
    var onBackInvoked       = false
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.onBackInvoked = false
        btnChangePassword.isHidden = true
        btnSave.isHidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func doChangePassword(_ sender: AnyObject) {
        if !validateFields() {
            return
        }
        if txtOldPassword.text != txtNewPassword.text {
            let userInfo = Utils.sharedInstance.userInfo
            userInfo.password       = txtNewPassword.text!
            userInfo.oldPassword    = txtOldPassword.text!
            userInfo.newPassword    = txtNewPassword.text!
            userInfo.changePassword()
        }
        showSuccessNotification("Password Changed Successfully")
        onBack(sender)
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBack(_ sender: AnyObject) {
        self.onBackInvoked = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(txtOldPassword) {
            editingOldPassword = true
            txtOldPassword.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.onBackInvoked {
            return
        }
        if textField.isEqual(txtOldPassword) {
            Async.userInteractive {
                self.checkOldPassword()
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate func validateFields() -> Bool {
        if txtNewPassword.text!.isEmpty {
            showWarningMessage("New Password", subTitle: "Cannot be empty")
            return false
        }
        if txtConfirmPassword.text != txtNewPassword.text {
            showWarningMessage("New Password", subTitle: "The New Password and confirm password doesn't match")
            return false
        }
        if editingOldPassword {
            return checkOldPassword()
        }
        return true
    }
    
    fileprivate func checkOldPassword() -> Bool {
        if IJReachability.isConnectedToNetwork() {
            do {
                
                let response = try PFCloud.callFunction(CloudCodeMethods.checkPassword.rawValue, withParameters: ["password": self.txtOldPassword.text!])
                
                let res = response as! Bool
                
                if res {

                    Async.main {
                        self.btnChangePassword.isHidden = false
                        self.btnSave.isHidden = false
                    }

                    Utils.sharedInstance.resetIncorrectPasswordCount()
                    self.editingOldPassword = false
                    return true
                } else {
                    self.editingOldPassword = true
                    Async.main {
                        if Utils.sharedInstance.incorrectPasswordCount < 1 {
                            showWarningMessage("Incorrect Password", subTitle: "If you have forgotten password, use Forgot Password button here")
                            
                            Utils.sharedInstance.userInfo.logout()
                            self.tabBarController?.dismiss(animated: true, completion: nil)
                        } else {
                            self.txtOldPassword.textColor = UIColor.red
                            showWarningMessage("Password", subTitle: "Old Password is Incorrect, will logout after \(Utils.sharedInstance.incorrectPasswordCount) incorrect password tries")
                            Utils.sharedInstance.incorrectPasswordCount -= 1
                        }
                        
                    }
                }
                
            } catch {
                // showWarningMessage("Error", subTitle: "Password")
            }
        } else {
            Async.main {
                showWarningMessage("No Internet", subTitle: "Password changes can happen only when there is network")
            }
        }
        return false
    }
}
