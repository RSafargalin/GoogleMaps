//
//  LoginView.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

protocol ContentView: UIView {
    
    var scrollView: UIScrollView { get }

}

final class LoginView: UIView, ContentView {
    
    // MARK: - Public Variables
    
    let scrollView: UIScrollView
    let usernameContainerView: ContainerForTextFieldWithLabelProtocol
    let passwordContainerView: ContainerForTextFieldWithLabelProtocol
    let signInButton: UIButton
    
    // MARK: - Private Variables
    
    private let stackView: UIStackView
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        
        stackView = UIStackView()
        scrollView = UIScrollView()
        usernameContainerView = DefaultContainerForTextFieldWithLabel(with: "Login", and: "Login...")
        passwordContainerView = DefaultContainerForTextFieldWithLabel(with: "Password", and: "Password...")
        signInButton = UIButton()
        super.init(frame: frame)
        self.configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func configureUI() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = Constant.Sizes.Default.spacing.rawValue
        stackView.addArrangedSubview(usernameContainerView)
        stackView.addArrangedSubview(passwordContainerView)
        stackView.addArrangedSubview(signInButton)
    
        usernameContainerView.autoCorrection(.no)
        passwordContainerView.autoCorrection(.no)
        passwordContainerView.isSecureTextField(true)
        
        signInButton.setTitle("Join", for: .normal)
        signInButton.tintColor = .white
        signInButton.backgroundColor = .systemOrange
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.layer.cornerRadius = Constant.Sizes.Default.Layer.cornerRadius.rawValue
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                               constant: self.layoutMargins.left * 2),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                constant: -self.layoutMargins.left * 2),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                           constant: self.layoutMargins.top),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,
                                              constant: self.layoutMargins.top),
            
            signInButton.heightAnchor.constraint(equalToConstant: Constant.Sizes.Default.Button.TapAreaSize.rawValue),
        ])

    }
}
