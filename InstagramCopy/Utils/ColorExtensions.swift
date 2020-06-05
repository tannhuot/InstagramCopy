//
//  ColorExtensions.swift
//  InstagramCopy
//
//  Created by Huot on 12/2/19.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static let getActiveButtonColor = rgb(red: 17, green: 154, blue: 237)
    static let separatorColor = rgb(red: 230, green: 230, blue: 230)
}
