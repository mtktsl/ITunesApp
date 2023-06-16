//
//  UIColor+Extension.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 15.06.2023.
//

import UIKit

extension UIColor {
    static let hueMax = 360.0
    
    static let playButtonColor = UIColor(
        hue: 242.0 / hueMax,
        saturation: 0.49,
        brightness: 0.9,
        alpha: 1
    )
    
    static let tabBarColor = UIColor(
        hue: 0 / hueMax,
        saturation: 0,
        brightness: 0.95,
        alpha: 1
    )
}
