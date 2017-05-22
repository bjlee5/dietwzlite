//
//  Array+Extension.swift
//  Moblzip
//
//  Created by TheTerminator on 7/14/16.
//  Copyright © 2016 Moblzip LLC. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element == Int {
    var total: Int {
        guard !isEmpty else { return 0 }
        return reduce(0, +)
    }
    var average: Double {
        return Double(total)/Double(count.toIntMax())
    }
}

extension Collection where Iterator.Element == Double {
    var total: Double {
        guard !isEmpty else { return 0 }
        return  reduce(0, +)
    }
    var average: Double {
        guard !isEmpty else { return 0 }
        return  total / Double(count.toIntMax())
    }
}
