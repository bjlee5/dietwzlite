//
//  UITextField+Extension.swift
//  Moblzip
//
//  Created by TheTerminator on 7/14/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation
import UIKit

/// MARK: Add NextField to UITextfield
private var kAssociationKeyNextField: UInt8 = 0
extension UITextField {
    @IBOutlet var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}