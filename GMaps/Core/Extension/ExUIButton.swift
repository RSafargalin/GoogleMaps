//
//  ExUIButton.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

extension UIButton {
    
    // MARK: Enums
    
    enum ButtonState {
        case enabled,
             disabled
    }
    
    // MARK: Public methods
    
    func set(_ state: ButtonState, enabledColor: UIColor = .systemOrange, disabledColor: UIColor = .darkGray, sleep time: UInt32 = 0) {
        if time > 0 {
            sleep(time)
        }
        
        switch state {
        case .enabled:
            DispatchQueue.main.async {
                self.isEnabled = true
                self.backgroundColor = .systemOrange
            }
            
        case .disabled:
            DispatchQueue.main.async {
                self.isEnabled = false
                self.backgroundColor = .darkGray
            }
        }
        
    }
    
}
