//
//  ShowAlerts.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 2/6/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation
//import UIKit
import SCLAlertView
import Whisper
import Crashlytics // If using Answers with Crashlytics
//import Answers // If using Answers without Crashlytics


//func showErrorAlertsForMessageCode(msgCode: Int) {
//    UIAlertView(title: "Error", message: messages[msgCode], delegate: nil, cancelButtonTitle: "OK").show()
//}
//
//func showWarningAlertsForMessageCode(msgCode: Int) {
//    UIAlertView(title: "Warning", message:  messages[msgCode], delegate: nil, cancelButtonTitle: "OK").show()
//}
//
//
//func showErrorAlertsForMessageCode(message: String , viewController : UIViewController) {
////    UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
//    showAlerts("Error", message: message, viewController: viewController)
//}
//
//func showWarningAlertsForMessageCode(message: String, viewController : UIViewController) {
////    UIAlertView(title: "Warning", message:  message, delegate: nil, cancelButtonTitle: "OK").show()
//    showAlerts("Warning", message: message, viewController: viewController)
//}
//
//func showMessage(mesage: String, viewController: UIViewController) {
//    showAlerts("", message: mesage, viewController: viewController)
//}
//
//func showAlerts(title: String, message: String, viewController : UIViewController) {
//    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//    
//    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
////    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
//    viewController.presentViewController(alertController, animated: true, completion: nil)
//}

func dlog(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column){
//    print(message)
//    let msg = "\(file) : \(function) : \(line) - \(message)"
    var msg = ""
    
    
    if Thread.isMainThread {
        msg = "[main] "
    }
    else {
        if let threadName = Thread.current.name , !threadName.isEmpty {
            msg = "[" + threadName + "] "
        }
//        else if let queueName = String(validatingUTF8: DISPATCH_CURRENT_QUEUE_LABEL.label) , !queueName.isEmpty {
//            msg = "[" + queueName + "] "
//        }
        else {
            msg = "[" + String(format:"%p", Thread.current) + "] "
        }
    }
    
    
    msg = msg + "[\((file as NSString).lastPathComponent):\(line)][\(function)] - \(message)"
    
    print("\(msg)")
//    return msg
}


func derror(_ message: String, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
//func derror(message: String, file: String = #function, function: String = #file, line: Int = #line, column: Int = #column) {
//    let msg = "\((file as NSString).lastPathComponent) : \(function) : \(line) - \(message)"
    var msg = "[\((file as NSString).lastPathComponent):\(line)][\(function)] - \(message)"
    if Thread.isMainThread {
        msg = "[main] " + msg
    }
    else {
        if let threadName = Thread.current.name , !threadName.isEmpty {
            msg += "[" + threadName + "] " + msg
        }
//        else if let queueName = String(validatingUTF8: DISPATCH_CURRENT_QUEUE_LABEL.label) , !queueName.isEmpty {
//            msg += "[" + queueName + "] " + msg
//        }
        else {
            msg += "[" + String(format:"%p", Thread.current) + "] " + msg
        }
    }
    Answers.logCustomEvent(withName: "Error", customAttributes: ["msg": msg])
    print("\(msg)")
}

func showSuccessNotification(_ message: String) {
    var messageMurmur = Murmur(title: message)
    messageMurmur.titleColor = UIColor.black
    messageMurmur.backgroundColor = UIColor.green
    show(whistle: messageMurmur)
    
//    Whistle(messageMurmur)
}

func showNewDayStarted() {
    let alert = SCLAlertView()
//    alert.addButton("Fill Yesterday's data") {
////        Utils.sharedInstance
//        Utils.sharedInstance.isPreviousDay = true
//        
//        
//    }
    //        alert.showCloseButton = false
//    var subTitle = ""
//    subTitle = "New day has started, looks like you haven't finished entering data from yesterday, do you want to finish it?"
//    var closeButtonTitle = "OK"
//    closeButtonTitle = "OK - Continue with Today"
    alert.showSuccess("New Day Started", subTitle: "", closeButtonTitle: "OK", timeout: nil, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
}

func showSuccessMessage(_ message: String, subTitle: String = "") {
    let alert = SCLAlertView()
    alert.showSuccess(message, subTitle: subTitle)
}

func showInfoMessage(_ message: String) {
    let alert = SCLAlertView()
    alert.showInfo(message, subTitle: "", closeButtonTitle: "OK", timeout: nil, colorStyle: ThemeColors.Teal.toHexString(), colorTextButton: UIColor.white.toHexString(), circleIconImage: nil)
}

func showWarningMessage(_ message: String, subTitle: String = "") {
    let alert = SCLAlertView()
    alert.showError(message, subTitle: subTitle)
}

let messages = [
    someError: "Some Error"
]

