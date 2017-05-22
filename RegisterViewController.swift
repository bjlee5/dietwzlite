//
//  RegisterViewController.swift
//  Moblzip
//
//  Created by Moblzip, LLC on 11/11/14.
//  Copyright (c) 2014 Moblzip, LLC. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var isEditingMode = false
    var showPassword = true
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var usernameFld: UITextField!
    @IBOutlet weak var emailFld: UITextField!
    @IBOutlet weak var passwordFld: UITextField!
    @IBOutlet weak var confirmPassFld: UITextField!
    @IBOutlet weak var ageFld: UITextField!
    @IBOutlet weak var genderSeg: UISegmentedControl!
    
    // MARK: - View Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupKeyboardNavigation()

        nextBtn.isHidden = true
        doneBtn.isHidden = true
        confirmPassFld.delegate = self
        
        isEditingMode ? setupForEditingMode() : setupForRegisterMode()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func onBack(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDone(_ sender: AnyObject) {
        if !checkValidation() {
            return
        }
        
        updateUserInfo()
        onBack(sender)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        if isEditingMode {
            onDone(sender)
        } else {
            _ = shouldPerformSegue(withIdentifier: "signin", sender: sender)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case usernameFld:
            emailFld.becomeFirstResponder()
        case emailFld:
            if showPassword {
                passwordFld.becomeFirstResponder()
            } else {
                ageFld.becomeFirstResponder()
            }
        case passwordFld:
            confirmPassFld.becomeFirstResponder()
        case confirmPassFld:
            ageFld.becomeFirstResponder()
        case ageFld:
            ageFld.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(confirmPassFld) && (confirmPassFld.text!.isEmpty || confirmPassFld.text != passwordFld.text) {
            showWarningMessage("Password", subTitle: "The password doesn't match")
        }
    }
   
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "signin" {
            
            if !checkValidation() {
                return false
            }
            
            let registerUserError = registerUser()
            if registerUserError != "" {
                showWarningMessage("", subTitle: registerUserError)
                return false
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            return Utils.sharedInstance.userInfo.logged
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "privacy" {
            let infoController = segue.destination as! InfoViewController
            infoController.infoItem = InfoItem.Data.PrivacyPolicy
        }
    }
    
    // MARK: - Private
    
    fileprivate func setupForEditingMode() {
        self.titleLbl.text = "My Profile"
        self.btnSave.setTitle("Update Profile", for: UIControlState())
        self.btnSave.setTitle("Updating ... ", for: UIControlState.highlighted)
        self.btnSave.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
        
        let userInfo = Utils.sharedInstance.userInfo
        usernameFld.text = userInfo.username
        emailFld.text = userInfo.email
        
        usernameFld.isHidden = true
        emailFld.isHidden = true
        
        ageFld.text = "\(userInfo.age)"
        if userInfo.gender == "m" {
            genderSeg.selectedSegmentIndex = 0
        } else if userInfo.gender == "f" {
            genderSeg.selectedSegmentIndex = 1
        }
        self.hideChangePassword()
    }
    
    fileprivate func setupForRegisterMode() {
        Utils.sharedInstance.userInfo.userProfile = UserProfile()
        Utils.sharedInstance.userInfo.userProfile.initializeData()
        self.titleLbl.text = "Register"
        self.btnSave.setTitle("Register", for: UIControlState())
        self.btnSave.setTitle("Registering ... ", for: UIControlState.highlighted)
        self.btnSave.setTitleColor(UIColor.darkGray, for: UIControlState.highlighted)
    }
    
    fileprivate func updateUserInfo() {
        let userInfo = getUserInfoFromUI(false)
        userInfo.save()
    }
    
    fileprivate func registerUser() -> String {
        let userInfo = getUserInfoFromUI(true)
        return userInfo.registerUser()
    }
    
    fileprivate func getUserInfoFromUI(_ doLogout: Bool) -> UserSession {
        let userInfo = Utils.sharedInstance.userInfo
        if doLogout {
            userInfo.logout()
        }
        userInfo.username = usernameFld.text!.lowercased()
        userInfo.email = emailFld.text!.lowercased()
        
        if showPassword {
            userInfo.password = passwordFld.text!
        }
        
        userInfo.age = Int(ageFld.text!)!
        userInfo.gender = (genderSeg.selectedSegmentIndex == 0) ? "m" : "f"
        
        return userInfo
    }
    
    /// hide password vies and show the button change password
    fileprivate func hideChangePassword() {
        passwordFld.isHidden = true
        confirmPassFld.isHidden = true
        showPassword = false
    }
    
    fileprivate func setupKeyboardNavigation() {
        usernameFld.returnKeyType = .next
        emailFld.returnKeyType = .next
        passwordFld.returnKeyType = .next
        confirmPassFld.returnKeyType = .next
        ageFld.returnKeyType = .next
    }
    
    fileprivate func checkValidation() -> Bool {
        
        if !IJReachability.isConnectedToNetwork() {
            showWarningMessage("No Network", subTitle: msg_no_internet_at_register)
            return false
        }
        
        if usernameFld.text!.isEmpty {
            showWarningMessage("User Name", subTitle: "Please enter the username")
            return false
        }
        if emailFld.text!.isEmpty {
            showWarningMessage("Email", subTitle: "Please enter your email")
            return false
        }
        
        if showPassword {
            if passwordFld.text!.isEmpty {
                showWarningMessage("Password", subTitle: "Please enter the password")
                return false
            }
            if confirmPassFld.text!.isEmpty || confirmPassFld.text != passwordFld.text {
                showWarningMessage("Password", subTitle: "The password doesn't match")
                return false
            }
        }
        if ageFld.text!.isEmpty {
            showWarningMessage("Age", subTitle: "Please enter the age")
            return false
        }
        if genderSeg.selectedSegmentIndex == UISegmentedControlNoSegment {
            showWarningMessage("Gender", subTitle: "Please select your gender")
            return false
        }
        return true
    }
}
