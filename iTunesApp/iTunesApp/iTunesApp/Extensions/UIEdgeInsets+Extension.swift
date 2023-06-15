//
//  UIEdgeInsets+Extension.swift
//  iTunesApp
//
//  Created by Metin Tarık Kiki on 14.06.2023.
//

import UIKit

extension UIEdgeInsets {
    
    init(_ inset: CGFloat) {
        self.init(inset, inset, inset, inset)
    }
    
    init(_ top: CGFloat = 0,
         _ left: CGFloat = 0,
         _ bottom: CGFloat = 0,
         _ right: CGFloat = 0
    ) {
        self.init(top: top,
                  left: left,
                  bottom: bottom,
                  right: right)
    }
}
