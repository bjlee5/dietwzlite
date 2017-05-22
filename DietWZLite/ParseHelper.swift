//
//  Messages.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 2/6/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation



///All the parse class names that are used in this application
enum ParseClassName : String {
    
    case Transactions        = "Transactions"
    case LocalTransactions   = "LocalTransactions"
    case CloudTransactions   = "CloudTransactions"
    
    case HealthyAlternatives = "HealthyAlternatives"
    case Recipes             = "Recipes"
    
    case Category            = "Category"
    case DailyCategory       = "DailyCategory"
    
    case DailyInfo           = "DailyInfo"
    case DeviceInfo          = "DeviceInfo"
    case User                = "_user"
    case DWBaseParse         = "DWBaseParse"
    
    
    case FriendGroup         = "FriendGroup"
    case Invitation          = "Invitation"
    case UserGroupPreference = "UserGroupPreference"
    
    case UserProfile            = "UserProfile"
    
}

/// All the pin names that are used locally to track sync operations
enum ParsePin: String {
    case Local               = "Locally"  //Pin Name
    case SaveToCloud         = "SaveToCloud"
    case DeleteFromCloud     = "DeleteFromCloud"
    case HealthyAlternatives = "HealthyAlternatives"
    case VersionControl      = "VersionControl"
    case Friends             = "Friends"
}


enum ParseColumnName {
    
    enum FriendGroup : String {
        case InvitedUserEmails      = "invitedUserEmails"
        case FriendUserIds          = "friendUserIds"
    }
    
    enum DailyInfo : String {
        case choicePoints           = "choicePoints"
    }
    
    enum User : String {
        case UGP                    = "userGroupPreferences"
        case AverageCyclePoints     = "averageCyclePoints"
        case DailyCyclePoints       = "dailyCyclePoints"  //Total Choice Points at the end of each 2­day cycle
        case DailyChoicePoints      = "dailyChoicePoints" //Daily Choice Points
        case ChoicePointsLUD        = "choicePointsLUD"
        case Weight                 = "weight"
        case UserName               = "username"
        case UpdateFromHandHeld     = "updateFromHandHeld"
        case OldPassword            = "oldPassword"
        case NewPassword            = "newPassword"
        case UserProfile            = "userProfile"
    }
}

enum UserGroupStatus: String {
    case Accepted   = "accepted"
    case Invited    = "invited"
}