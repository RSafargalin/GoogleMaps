//
//  ContainerForTextFieldWithLabelProtocol.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

protocol ContainerForTextFieldWithLabelProtocol: UIView {

    typealias Title = String
    typealias Placeholder = String
    
    var textField: UITextField { get }
    
    func setTitle(_ text: Title) -> Void
    func setPlaceholder(_ text: Placeholder) -> Void
    func getText() -> String?
    func shake() -> Void
    func setText(_ text: String) -> Void
    func isSecureTextField(_ value: Bool)
    func autoCorrection(_ value: UITextAutocorrectionType)
    
    init(with title: Title, and placeholder: Placeholder)
}
