//
//  ExUITextField.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import UIKit

extension UITextField {
    
    func shake() {
        
        if let text = self.text, text.isEmpty {
            let animation = CABasicAnimation(keyPath: "position")
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
            
            let group = CAAnimationGroup()
            group.duration = 0.07
            group.repeatCount = 3
            group.autoreverses = true
            group.animations = [animation]
            self.layer.add(group, forKey: nil)
        }
        
    }
    
}
