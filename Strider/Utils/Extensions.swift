//
//  Extensions.swift
//  InstagramFirebase
//
//  Created by Brian Voong on 3/18/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func deepSkyBlue() -> UIColor {
        return UIColor.rgb(red: 0, green: 191, blue: 255)
    }
    
    static func friskOrange() -> UIColor {
        return UIColor.rgb(red: 255, green: 153, blue: 51)
    }
    
    static func facebookBlue() -> UIColor {
        return UIColor.rgb(red: 59, green: 89, blue: 152)
    }
    
    static func googleRed() -> UIColor {
        return UIColor.rgb(red: 238, green: 99, blue: 99)
    }
    
    static func striderYellow() -> UIColor {
        return UIColor.rgb(red: 252, green: 220, blue: 59)
    }
    
    static func twitterBlue() -> UIColor {
        return UIColor.rgb(red: 0, green: 172, blue: 237)
    }
    
    static func seagrassGreen() -> UIColor {
        return UIColor.rgb(red: 60, green: 179, blue: 113)
    }
    
    static func striderGray() -> UIColor {
        return UIColor.rgb(red: 242, green: 242, blue: 242)
    }
    
    static func darkBlue() -> UIColor {
        return UIColor.rgb(red: 0, green: 0, blue: 52)
    }
}

extension CGColor{
    public class var googleRed: CGColor {
        return UIColor(red: 238/255, green: 99/255, blue: 99/255, alpha: 1).cgColor
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension UIView {
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        var viewDict = [String: UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDict[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict))
    }
}

