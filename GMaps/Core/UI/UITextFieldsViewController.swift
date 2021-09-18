//
//  UITextFieldsViewController.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

///
/// - Warning: You need to override the loadview method and, after calling the super method, assign the view to your view, which implements the contentview protocol
/// - example:
/// ````
/// override func loadView() {
///     self.view = SignInView()
/// }
/// ````
class UITextFieldsViewController: UIViewController {
    
    
    // MARK: - Private properties
    
    private var contentView: ContentView? {
        return self.view as? ContentView
    }
    
    // MARK: - Life cycle
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func getView<ViewType: UIView>(_ type: ViewType.Type) -> ViewType {
        
        if let view = self.view as? ViewType {
            return view
        } else {
            return type.init(frame: self.view.frame)
        }
    }
    
    func setup() {
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(_:)))
        guard let contentView = contentView else {
            fatalError()
        }
        contentView.scrollView.addGestureRecognizer(scrollViewTap)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
    }
}

// MARK: - Extension SignInViewController

extension UITextFieldsViewController {
    
    @objc func scrollViewTapped(_ sender: UITapGestureRecognizer) {
        contentView?.scrollView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        contentView?.scrollView.contentInset = inset
        contentView?.scrollView.scrollIndicatorInsets = inset
        
    }
    
    @objc func keyboardWillHide() {
        contentView?.scrollView.contentInset = .zero
    }
    
}
