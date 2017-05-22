//
//  Constants.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 2/6/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

let someError = 0


struct DIETWZ_URL {
//        static let METEOR = "https://metdw1.herokuapp.com/"  //production
//        static let PARSE  = "http://lit-ridge-52419.herokuapp.com/parse" //production
    
//        static let METEOR = "https://mbz-stage-meteor2.herokuapp.com/" //staging
//        static let PARSE  = "http://mbz-stage-parseserver2.herokuapp.com/parse" //staging
    
    static let METEOR = "https://www.dietwz.net/"   //generic
    static let PARSE = "http://parseserver.dietwz.biz/parse"  //generic
    
    static let ForgotPassword   = DIETWZ_URL.METEOR + "forgotPassword"
    static let ModifyUserName   = DIETWZ_URL.METEOR + "modifyusername"
    static let ModifyEmail      = DIETWZ_URL.METEOR + "modifyemail"
}

struct SystemCategory {

    static let Fruits = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .Fruits, limit: 4)
    static let Veggies = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .Veggies, limit: 5)
    static let HealthySnacks = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .HealthySnacks, limit: 3)
    static let SugarySnacks = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .SugarySnacks, limit: -3)
    static let UnHealthyCarbs = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .UnhealthyCarbs, limit: -3)
    static let SugaryDrinks = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .SugaryDrinks, limit: -3)
    static let Alcohol = CategoryInfo(userDefinedCategory: false, mode: .counter, label: .Alcohol, limit: -3)
    
    static let Exercise = CategoryInfo(userDefinedCategory: false, mode: .question, label: .Exercise, limit: -2, value: -1)
    
    static let Weight = CategoryInfo(userDefinedCategory: false, mode: .weight, label: .Weight)
}

enum ChartType : String {
    case Scatter      = "ScatterChart"
    case Line         = "LineChart"
    case Bar          = "BarChart"
    case ChoicePoints = "ChoicePoints" //a bar graph, with calculated data over 2 day period
    case MealChoices  = "MealChoices" // a scatter graph with four options (skip, normal, light, excess), data is in daiyinfo
}

enum MealType : String {
    case Breakfast, Lunch, Dinner
    static let allValues: [MealType] = [.Breakfast, .Lunch, .Dinner]
}

enum MealWeight : Int, StringValueEnum {
    
    case skip
    case excess
    case light
    case normal

    var points: Int {
        switch self {
        case .skip:
            return -1
        case .excess:
            return 0
        case .normal:
            return 1
        case .light:
            return 2
        }
    }
    
    var stringValue: String {
        switch self {
        case .skip:
            return "Skip"
        case .excess:
            return "Excess"
        case .normal:
            return "Normal"
        case .light:
            return "Light"
        }
    }
}

enum CategoryMode : Int, StringValueEnum {
    
    case unknown
    case question
    case counter
    case numeric
    case weight
    case multiChoice
    
    var chartType: ChartType? {
        
        switch self {
        case .counter:
            return .Bar
        case .numeric:
            return .Line
        case .question:
            return .Scatter
        default:
            return nil
        }
    }
    
    var stringValue: String {
        
        switch self {
        case .unknown:
            return "Unknown"
        case .question:
            return "Question"
        case .counter:
            return "Counter"
        case .numeric:
            return "Numeric"
        case .weight:
            return "Weight"
        case .multiChoice:
            return "MultiChoice"
        }
    }
}

protocol StringValueEnum {
    var stringValue: String { get }
}

struct ThemeColors {
    
    static let Teal = UIColor(red: 0.086, green: 0.576, blue: 0.647, alpha: 1.000)
    static let Green = UIColor(red: 0.196, green: 0.612, blue: 0.169, alpha: 1.000)
    
    static let deleteButtonColor = UIColor(red: 1, green: 0.2, blue: 0.143, alpha: 1.000)
    static let inviteButtonColor = UIColor(red: 0.05, green: 0.57, blue: 0.64, alpha: 1.000)
    static let saveButtonColor = UIColor(red: 0.000, green: 0.4, blue: 1.000, alpha: 1.000)
    static let cancelButtonColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    static let TabBarColor = UIColor(red: 0.125, green: 0.125, blue: 0.110, alpha: 1.000) //UIColor(red: 0.192, green: 0.192, blue: 0.192, alpha: 1.000)
    
    static let goodChoiceBackground = UIColor(red: 0.318, green: 0.318, blue: 0.318, alpha: 1.000)

}

enum CloudCodeMethods:String {
    case checkPassword, changePassword, getGroupFriendsData
}

struct InfoItem {
    
    let infoTitle: Title
    
    enum Title : String {
        
        //Home
        case DailyChoices                       = "Enter Your Daily Choices Below"
        
        //More table
        case EditAccount                        = "Edit Acccount"
        case EditDataAndPreferences             = "Edit My Data and Preferences"
        case ChangeDayInCycle                   = "Change day in cycle"
        case Reset                              = "Reset"
        
        //Info
        case HealthyAlternativesAndAdvice       = "Healthy Ideas and Advice"
        case RestaurantTips                     = "Restaurant Tips"
        
        //HealthAlternativesDatabase
        
        case HealthyAlternativesDatabase        = "Healthy Ideas Database"
        
        //Privacy Policy
        case PrivacyPolicy                      = "Privacy Policy"
    }
    
    enum Data : String {
        
        case AboutUs                            = "About"
        case CustomCategory                     = "Custom Category"
        case Friends                            = "Friends & Groups"
        case PointDetail                        = "Choice Points"
        
        //Home info
        case Alcohol                            = "Alcohol"
        case Breakfast                          = "Breakfast"
        case Dinner                             = "Dinner"
        case Exercise                           = "Exercise"
        case Fruits                             = "Fruits"
        case HealthySnacks                      = "Healthy Snacks"
        case Lunch                              = "Lunch"
        case SugarySnacks                       = "Sugary Snacks"
        case SugaryDrinks                       = "Sugary Drinks"
        case UnhealthyCarbs                     = "Unhealthy Carbs"
        case Veggies                            = "Veggies"
        case Weight                             = "Weight"
        
        //More table options
        case EditPersonalData                   = "Edit Personal Data"
        case ShowEmailUserName                  = "Show Email and User Name"
        case ChangePassword                     = "Change Password"
        case ResetPassword                      = "Forgot Password"
        case AddDeleteOptionalCategoryTracking  = "Add/delete optional category to track"
        case ChangeUserName                     = "Change User Name"
        case ChangeEmail                        = "Change Email"
        case Logout                             = "Logout"
        case GoBackOneDay                       = "Go back one day (finish entries for yesterday)"
        case ReturnToCurrentDay                 = "Return to current day"
        case ResetCurrentCycle                  = "Reset current cycle"
        case ResetCurrentDay                    = "Reset current day"
        
        //Info table options
        case SearchDatabase                     = "Search Database of Healthy Food/Beverage Ideas"
        case FoodPortionTips                    = "Food Portion Tips"
        case NutritionTips                      = "Nutrition Tips"
        case General                            = "General"
        case American                           = "American"
        case Chinese                            = "Chinese"
        case French                             = "French"
        case Indian                             = "Indian"
        case Italian                            = "Italian"
        case Japanese                           = "Japanese"
        case Korean                             = "Korean"
        case Mexican                            = "Mexican"
        case MiddleEastern                      = "Middle Eastern/Greek"
        case Thai                               = "Thai"
        
        //Privacy Policy
        case PrivacyPolicy                      = "Privacy Policy"
        
        var displayFormat: String {
            switch self {
            case .General, .American, .Chinese, .French, .Indian, .Italian, .Japanese, .Korean, .Mexican, .MiddleEastern, .Thai:
                return self.rawValue + " Restaurant Tips"
            case .Weight:
                return "Enter your daily weight:"
            case .Exercise:
                return "Did you get some exercise today?"
            default:
                return self.rawValue
            }
        }
        
        var htmlFileNameFormat: String {
            var value = self.rawValue
            value.removeCharactersInSet(" &/:")
            return value
        }
    }
    
    //  https://fortawesome.github.io/Font-Awesome/cheatsheet/
    enum Icon : String {
        case Edit                               = "fa-edit"
        case Key                                = "fa-key"
        case Ellipsis                           = "fa-ellipsis-h"
        case Plus                               = "fa-plus"
        case CalendarMinus                      = "fa-calendar-minus-o"
        case CalendarPlus                       = "fa-calendar-plus-o"
        case Refresh                            = "fa-refresh"
        case Clock                              = "fa-clock-o"
        case User                               = "fa-user"
        case Email                              = "fa-send"
        case Logout                             = "fa-lock"
    }
    
    init(infoTitle: Title) {
        self.infoTitle = infoTitle
    }
    
    //list items in the order they should be displayed
    func dataItems() -> [(data: Data, icon: Icon?)] {
        
        switch self.infoTitle {
        case .DailyChoices:
            return [
                (.Breakfast, nil),
                (.Lunch, nil),
                (.Dinner, nil),
                (.Fruits, nil),
                (.Veggies, nil),
                (.HealthySnacks, nil),
                (.SugarySnacks, nil),
                (.UnhealthyCarbs, nil),
                (.SugaryDrinks, nil),
                (.Alcohol, nil),
                (.Exercise, nil),
                (.Weight, nil)
            ]
        case .EditAccount:
            return [
                (.Logout, .Logout),
                (.ChangeUserName, .User),
                (.ChangeEmail, .Email),
                (.ChangePassword, .Key),
                (.ResetPassword, .Ellipsis)
            ]
        case .EditDataAndPreferences:
            return [
//                (.AddDeleteOptionalCategoryTracking, .Plus),
                (.EditPersonalData, .Edit),
                (.ShowEmailUserName, .User)
            ]
        case .ChangeDayInCycle:
            return [
                (.GoBackOneDay, .CalendarMinus),
                (.ReturnToCurrentDay, .CalendarPlus)
            ]
        case .Reset:
            return [
                (.ResetCurrentCycle, .Refresh),
                (.ResetCurrentDay, .Clock)
            ]
        case .HealthyAlternativesAndAdvice:
            return [
                (.SearchDatabase, nil),
                (.FoodPortionTips, nil),
                (.NutritionTips, nil)
            ]
        case .RestaurantTips:
            return [
                (.General, nil),
                (.American, nil),
                (.Chinese, nil),
                (.French, nil),
                (.Indian, nil),
                (.Italian, nil),
                (.Japanese, nil),
                (.Korean, nil),
                (.Mexican, nil),
                (.MiddleEastern, nil),
                (.Thai, nil)
            ]
        case .PrivacyPolicy:
            return [
                (.PrivacyPolicy, nil)
            ]
        case .HealthyAlternativesDatabase:
            return [] //these have to unfortunately be added dynamically because the categories are pulled from Parse
        }
    }
}
