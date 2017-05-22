//
//  UserSession.swift
//  Moblzip
//
//  Created by Niklas Olsson on 25/11/14.
//  Copyright (c) 2014 niklas. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class UserSession: NSObject {
    
    var email: String {
        didSet {
            email = email.lowercased()
        }
    }
    var password: String
    
    var logged: Bool
    var keepLogged: Bool
    var parseId: String
    
    var updateFromHandHeld: Bool
    var oldPassword: String
    var newPassword: String
    var parseUser: PFUser!
    var username: String
    
//    var username: String {
//        didSet {
//            username = username.lowercased()
//            userProfile.username = username
//        }
//    }
    
    var age: Int {
        get {return userProfile.age}
        set {userProfile.age = newValue}
    }
    
    var gender: String {
        get {return userProfile.gender}
        set {userProfile.gender = newValue}
    }
    
    var weight: Double {
        get {return userProfile.weight}
        set {userProfile.weight = newValue}
    }

    var choicePointsLUD: Date {
        get {return userProfile.choicePointsLUD as Date}
        set {userProfile.choicePointsLUD = newValue}
    }

    //30 day average cycle points
    var averageCyclePoints: Float {
        get {return userProfile.averageCyclePoints}
        set {userProfile.averageCyclePoints = newValue}
    }

    var dailyChoicePoints: Int {
        get {return userProfile.dailyChoicePoints}
        set {userProfile.dailyChoicePoints = newValue}
    }
    
    var dailyCyclePoints: Int {
        get {return userProfile.dailyCyclePoints}
        set {userProfile.dailyCyclePoints = newValue}
    }
    
    var name: String {
        get {return userProfile.name}
        set {userProfile.name = newValue}
    }
    
    var userGroupPreferencesAry: [UserGroupPreference] {
        get {return userProfile.userGroupPreferences}
        set {userProfile.userGroupPreferences = newValue}
    }
    
    
    var userProfile: UserProfile
    
    override init() {

        userProfile = UserProfile()
        userProfile.initializeData()

        username = ""
        //TODO: EMAIL should be case-insensitive
        email = ""
        password = ""
        oldPassword = ""
        newPassword = ""
        logged = false
        keepLogged = false
        updateFromHandHeld = true
        parseId = ""
        super.init()
    }
        
    func logout() {
        dlog("Saving before logout")
        Answers.logCustomEvent(withName: "Logout", customAttributes: ["userName" : username])
        Utils.sharedInstance.saveToParse()
        updateFromHandHeld = true
        logged = false
        keepLogged = false

//        userProfile = UserProfile()
//        userProfile.initializeData()
//        age = 0
//        gender = ""
//        parseId = ""
//        parseUser = nil
//        PFUser.logOut()
        
    }
    
    
    func isMan() -> Bool {
        return gender == "m"
    }
    
    func registerUser() -> String {
        //TODO figure out how to signup without a network connection
        
        let user = serializeToPFUser(PFUser())
        print("parseSignup - 1. Trying to signup \(user)")
        
        do {
            
            try user.signUp()
            userProfile.acl = Utils.sharedInstance.getPublicReadUserWriteACL()
            userProfile.username = username
            userProfile.saveInBackground()
            self.logged = true
            self.keepLogged = true
            Answers.logSignUp(withMethod: "iOS", success: 1, customAttributes: ["user": username])
            print("parse Signed up - 2.  \(user)")
            self.deSerializeFromPFUser(user)
            Utils.sharedInstance.appInitialize()
            return ""
            
        } catch let error as  NSError {
            dlog("\(error)")
            let errorString = error.userInfo["error"] as! NSString
            return errorString as String
        }
        catch  {
            derror("could not signup")
            return "Try again, Error during signup"
        }

        ///TODO - Go into each user group and find out if this email address is invited
        //if yes, create a user group preference for this user to that group and mark it invited
        // maybe defer it to cloud, more efficient
    }
    
    
    func changePassword() {
        
        let currentUser = Utils.sharedInstance.userInfo.parseUser
        
        if (currentUser != nil) {
            Utils.sharedInstance.saveToParse()
            let user = serializeToPFUser(currentUser!)
            user["mongoPW"] = ""
            user.saveInBackground()
            logout()
        } else {
            dlog("current user is nil so not changing password")
        }
        
    }
    
    func serializeToPFUser(_ user: PFUser) -> PFUser{
        user.username = username
        if(password != "") {
            user.password = password
            user["mongoPW"] = password
        }
        user.email = email
        
//        user["age"] = age
//        user["gender"] = gender
        user["logged"] = logged
        user["keepLogged"] = keepLogged
        
//        user[.AverageCyclePoints] = self.averageCyclePoints
//        user[.DailyChoicePoints] = self.dailyChoicePoints
//        user[.DailyCyclePoints] = self.dailyCyclePoints
//        user[.Weight] = self.weight
//        user[.ChoicePointsLUD] = self.choicePointsLUD
        user[.UpdateFromHandHeld] =  true as AnyObject?
        
        user[.OldPassword] = self.oldPassword as AnyObject?
        user[.NewPassword] = self.newPassword as AnyObject?
        
        user[.UserProfile] = self.userProfile
        
        return user
    }
    
    /// This is unnecessary method to by pass a bug in parse server, where password once set invalidates the user session token
    func serializeToPFUserForSave(_ user: PFUser) -> PFUser{
        user.username = username
//        if(password != "") {
//            user.password = password
//            user["mongoPW"] = password
//        }
        user.email = email
        
//        user["age"] = age
//        user["gender"] = gender
        user["logged"] = logged
        user["keepLogged"] = keepLogged
        
//        user[.AverageCyclePoints] = self.averageCyclePoints
//        user[.DailyChoicePoints] = self.dailyChoicePoints
//        user[.DailyCyclePoints] = self.dailyCyclePoints
//        user[.Weight] = self.weight
//        user[.ChoicePointsLUD] = self.choicePointsLUD
        user[.UpdateFromHandHeld] =  true as AnyObject?
        
        user[.OldPassword] = self.oldPassword as AnyObject?
        user[.NewPassword] = self.newPassword as AnyObject?
        
        user[.UserProfile] = self.userProfile
        
        return user
    }
    
    func deSerializeFromPFUser(_ user: PFUser)  {
        
        if user.username != nil {
            username = user.username!
            password = user["mongoPW"] as! String
            email = user.email!
            self.userProfile = user[.UserProfile] as! UserProfile
            logged = user["logged"] as! Bool
            keepLogged = user["keepLogged"] as! Bool
            updateFromHandHeld = true
            parseId = user.objectId!
            parseUser = user
        }
    }
    
    func save() {
        let currentUser = Utils.sharedInstance.userInfo.parseUser
        if (currentUser != nil) {
            userProfile.saveInBackground()
            let user = serializeToPFUserForSave(currentUser!)
//            user.saveInBackground()
            user.saveInBackground(block: { (success:Bool, error:Error?) in
                if success {
                    self.userProfile.saveInBackground()
                } else {
                    dlog("------> user save failed \(error)")
                }
            })
            
//            user.saveEventually(nil)
        } else {
            dlog("current user is nil so not saving it")
        }
    }
    
    func getParseUser() -> PFUser! {
        if parseUser != nil {
            return parseUser
        } else {
            login(self.username, password: self.password)
        }
        return parseUser
    }
    
    func login(_ email: String, password: String) {
//        println("email  - \(email) - pass - \(password)")
        Utils.sharedInstance.apiRequest("email  - \(email) - pass - \(password)")
        let user: PFUser! = try? PFUser.logIn(withUsername: email, password: password)
        print("loginWithParse  \(user) ")
        if user == nil {
            self.logged = false
        } else {
//            try! user[.UserProfile]!.fetch()
            try! user.fetch()
            
            self.userProfile = user[.UserProfile] as! UserProfile
            try! self.userProfile.fetchIfNeeded()
            
//            try! user[.UserProfile]!.fetch()
            self.deSerializeFromPFUser(user)
            self.logged = true
            self.logUser()
            Utils.sharedInstance.appInitialize()
        }
    }

    func logUser() {
        Answers.logLogin(withMethod: "iOS", success: 1, customAttributes: ["user": username])
        Crashlytics.sharedInstance().setUserEmail(self.email)
        Crashlytics.sharedInstance().setUserIdentifier(self.parseId)
        Crashlytics.sharedInstance().setUserName(self.username)
    }

    
}
