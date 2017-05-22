//
//  DWCommonUtils.swift
//  Moblzip
//
//  Created by Rick Sturgeon on 4/4/15.
//  Copyright (c) 2015 Moblzip LLC. All rights reserved.
//

import Foundation

/// MARK: Date Comparison methods
//TODO - Need to test, if date comapraison works #swift30changes

//public func ==(lhs: Date, rhs: Date) -> Bool {
//    return lhs == rhs || lhs.compare(rhs) == .orderedSame
//}
//
//
//public func <(lhs: Date, rhs: Date) -> Bool {
//    return lhs.compare(rhs) == .orderedAscending
//}
//
//public func >(lhs: Date, rhs: Date) -> Bool {
//    return lhs.compare(rhs) == .orderedDescending
//}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

//MARK: GCD helper variables
var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}

var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
}

var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
}

var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
}

var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
}
