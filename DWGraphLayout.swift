//
//  DWGraphLayout.swift
//  Moblzip
//
//  Created by Sujit Maharana on 10/25/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import UIKit

func degreesToRadians(_ degrees: Double) -> CGFloat {
    return CGFloat(M_PI * (degrees) / 180.0)
}

class DWGraphLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)! as [UICollectionViewLayoutAttributes]
        for attributes in layoutAttributes {
            let frame = attributes.frame
            //      attributes.transform = CGAffineTransformMakeRotation(degreesToRadians(-14))
            attributes.frame = frame.insetBy(dx: 12, dy: 0)
        }
        return layoutAttributes
    }
    
}
