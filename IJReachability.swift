// This file has MIT license, so using it here
// original file is here https://github.com/Isuru-Nanayakkara/IJReachability/blob/master/IJReachability/IJReachability/IJReachability.swift
// license is here https://github.com/Isuru-Nanayakkara/IJReachability/blob/master/LICENSE
// SO link - http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647

//
//  IJReachability.swift
//  IJReachability
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//  Modified by Dietwz

import Foundation
import SystemConfiguration

public enum IJReachabilityType {
    case wwan,
    wiFi,
    notConnected
}

open class IJReachability {
    
    /**
    :see: Original post - http://www.chrisdanielson.com/2009/07/22/iphone-network-connectivity-test-example/
    */
    open class func isConnectedToNetwork() -> Bool {
        

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        //TODO: check if parse is up and running
        // Create a heartbeat mechanism, the idea is to get a single piece of data from server, if the data is back, parse is alive, else don't 
        // 1. Check if parse.com or the server is up and running.
        // 2. Check if it is actually returning data.
        
        
        return (isReachable && !needsConnection) ? true : false
    }
    
    open class func isConnectedToNetworkOfType() -> IJReachabilityType {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return IJReachabilityType.notConnected
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return IJReachabilityType.notConnected
        }
        
      
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        //let isWifI = (flags & UInt32(kSCNetworkReachabilityFlagsReachable)) != 0
        
        if(isReachable && isWWAN){
            return .wwan
        }
        if(isReachable && !isWWAN){
            return .wiFi
        }
        
        return .notConnected
    }
    
}
