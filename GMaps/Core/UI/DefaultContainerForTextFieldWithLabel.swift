//
//  DefaultContainerForTextFieldWithLabel.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

class DefaultContainerForTextFieldWithLabel: UIView, ContainerForTextFieldWithLabelProtocol {
    
    // MARK: - Private property
    
    private let label: UILabel = UILabel()
    private let textField: UITextField = UITextField()
    
    // MARK: - Init
    
    required init(with text: String, and placeholder: String) {
        super.init(frame: CGRect())
        setup(label: text, with: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#file) \(#line)")
    }
    
    // MARK: - Public methods
    
    func setTitle(_ text: Title) {
        label.text = text
    }
    
    func setPlaceholder(_ text: Placeholder) {
        textField.placeholder = text
    }
    
    func getText() -> String? {
        return textField.text
    }
    
    func shake() {
        textField.shake()
    }
    
    func setText(_ text: String) {
        textField.text = text
    }
    
    func isSecureTextField(_ value: Bool) {
        textField.isSecureTextEntry = value
    }
    
    // MARK: - Private methods
    
    private func setup(label text: String = "Undefined", with placeholder: String = "Placeholder...") {
        
        addSubview(label)
        addSubview(textField)
        
        label.text = text
        textField.placeholder = placeholder
        
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        configureUI()
        
    }
    
    private func configureUI() {
        
        textField.borderStyle = .roundedRect

        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: Constant.Sizes.Label.rawValue),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor,
                                           constant: Constant.Margins.TextFieldFromLabel.rawValue),
            textField.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: Constant.Sizes.TextField.rawValue),
        ])
        
    }
    
}
