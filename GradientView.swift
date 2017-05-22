//
//  GradientView.swift
//  Moblzip
//
//  Created by Sujit Maharana on 10/25/15.
//  Copyright © 2015 Moblzip LLC. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    fileprivate var colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
    
    @IBInspectable var startColor: UIColor? {
        didSet {
            if let color = startColor {
                swapColorAtIndex(0, withColor: color.cgColor)
            }
        }
    }
    
    @IBInspectable var midColor: UIColor? {
        didSet {
            if let color = midColor {
                swapColorAtIndex(1, withColor: color.cgColor)
            }
        }
    }
   
    @IBInspectable var endColor: UIColor? {
        didSet {
            if let color = endColor {
                swapColorAtIndex(2, withColor: color.cgColor)
            }
        }
    }
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
    
    override func awakeFromNib() {
        prepareView()
    }
    
    override func prepareForInterfaceBuilder() {
        prepareView()
    }
    
    fileprivate func prepareView() {
        let layer = self.layer as! CAGradientLayer
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
    }
    
    fileprivate func swapColorAtIndex(_ index: Int, withColor color: CGColor) {
        colors.remove(at: index)
        colors.insert(color, at: index)
        let layer = self.layer as! CAGradientLayer
        layer.colors = colors
    }
    
}
