//
//  UIColor+Extensions.swift
//  snse
//
//  Created by Blake Barrett on 11/15/18.
//  Copyright © 2018 Blake Barrett. All rights reserved.
//

import UIKit

extension UIColor {
    
    //
    // Thanks to: https://stackoverflow.com/a/46934207
    //
    func toRGBAString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgba = [r, g, b, a].map { $0 * 255 }.reduce("", { $0 + String(format: "%02x", Int($1)) })
        return "#\(rgba)"
    }
    
    //
    // Thanks to: https://stackoverflow.com/a/36342082
    //
    public convenience init?(hexaDecimalString: String) {
        
        let r, g, b, a: CGFloat
        
        if hexaDecimalString.hasPrefix("#") {
            let start = hexaDecimalString.index(hexaDecimalString.startIndex, offsetBy: 1)
            let hexColor = String(hexaDecimalString[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}
