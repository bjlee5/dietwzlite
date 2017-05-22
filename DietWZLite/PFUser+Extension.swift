//
//  PFUser+Extension.swift
//  Moblzip
//
//  Created by TheTerminator on 7/12/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation

extension PFObject {
    
    subscript (columnName : ParseColumnName.User) -> AnyObject? {
        
        get {
            return self[columnName.rawValue] as AnyObject?
        }
        
        set(newType) {
            self[columnName.rawValue] = newType
        }
    }
    
    subscript (columnName : ParseColumnName.FriendGroup) -> AnyObject? {
        
        get {
            return self[columnName.rawValue] as AnyObject?
        }
        
        set(newType) {
            self[columnName.rawValue] = newType
        }
    }
    
    func removeObject<T: RawRepresentable>(_ object: AnyObject, forKey key: T) where T.RawValue == String {
        remove(object, forKey: key.rawValue)
    }
    
    func addUniqueObject<T: RawRepresentable>(_ object: AnyObject, forKey key: T) where T.RawValue == String {
        addUniqueObject(object, forKey: key.rawValue)
    }
}
