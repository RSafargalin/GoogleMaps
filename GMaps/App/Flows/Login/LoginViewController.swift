//
//  LoginViewController.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UITextFieldsViewController {
    
    // MARK: - Private properties
    
    private lazy var router: Router = RouterImpl(delegate: self)
    private let userManager: UserManager = UserManagerImpl()
    private let disposeBag: DisposeBag = DisposeBag()
    
    private lazy var goToSignUpBarButtonItem = UIBarButtonItem(title: "Sign Up",
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(goToSignUp))
    
    private var contentView: LoginView {
        return transformView(to: LoginView.self)
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        self.view = LoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    override func setup() {
        
        self.navigationItem.title = "Sign in..."
        
        self.navigationItem.rightBarButtonItem = goToSignUpBarButtonItem
        
        let signInButton = contentView.signInButton
        
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        Observable
            .combineLatest(contentView.usernameContainerView.textField.rx.text,
                           contentView.passwordContainerView.textField.rx.text)
            .map { login, password in
                guard let safeLogin = login,
                      !safeLogin.isEmpty,
                      
                      let safePassword = password,
                      safePassword.count >= 1
                else { return false }
                
                return true
            }
            .bind(onNext: { [weak signInButton] inputFilled in
                signInButton?.set(.onBool(value: inputFilled))
            }).disposed(by: disposeBag)
        
        super.setup()
        
    }
    
    @objc private func goToSignUp() {

        defer {
            DispatchQueue.main.async {
                self.goToSignUpBarButtonItem.isEnabled = false
            }
        }
        
        guard let username = try? usernameFieldValidation(),
              let password = try? passwordFieldValidation() else { return }
        
        goToSignUpBarButtonItem.isEnabled = true
        
        switch userManager.signUp(username: username, password: password) {
        case .success(let user):
            print(user)
            router.setAsRoot(.map())
            return
            
        case .failure(let error):
            print(error)
            return
        }
    }
    
    @objc private func signIn() {
        
        defer {
            DispatchQueue.main.async {
                self.contentView.signInButton.set(.enabled)
            }
        }
        
        guard let username = try? usernameFieldValidation(),
              let password = try? passwordFieldValidation() else { return }
        
        contentView.signInButton.set(.disabled)
        
        switch userManager.signIn(username: username, password: password) {
        case .success:
            router.setAsRoot(.map())
            
        case .failure(let error):
            print(error)
            break
            
        }
        
    }
    
    private enum LoginViewErrors: Error {
        case wrongFieldValue
    }
    
    private func usernameFieldValidation() throws -> String {
        guard let username = contentView.usernameContainerView.getText(),
              !username.isEmpty
        else {
            contentView.usernameContainerView.shake()
            throw LoginViewErrors.wrongFieldValue
        }
        
        return username
    }
    
    private func passwordFieldValidation() throws -> String {
        guard let password = contentView.passwordContainerView.getText(),
              !password.isEmpty
        else {
            contentView.passwordContainerView.shake()
            throw LoginViewErrors.wrongFieldValue
        }
        
        return password
    }
    
}
