//
//  ProfileView.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.09.2021.
//

import Foundation
import UIKit
import SwiftUI

protocol ProfileView: UIView {
    
    // Main info
    var avatarImageView: UIImageView { get }
    // Methods
    func update(avatar image: UIImage?)
    
}

final class ProfileViewImpl: UIView, ProfileView {
    
    // MARK: - Variables / Views
    
    private(set) lazy var avatarImageView: UIImageView = {
        let imageView: UIImageView = UIImageView(image: UIImage(systemName: "questionmark.square.dashed"))
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        return imageView
    }()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func update(avatar image: UIImage?) {
        DispatchQueue.main.async {
            self.avatarImageView.image = image
        }
    }
    
    
    // MARK: - Private Methods
    
    private func configureUI() {
        backgroundColor = .systemBackground
        
        addSubview(avatarImageView)
        
        // Layout Constraints
        
        let avatarImageViewWidth: CGFloat = UIScreen.main.bounds.width - (avatarImageView.layoutMargins.left * 4)
        
        NSLayoutConstraint.activate([
            
            avatarImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor,
                                                 constant: layoutMargins.top * 2),
            
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                     constant: layoutMargins.left * 2),
            
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                      constant: -layoutMargins.right * 2),
            
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor, multiplier: 1),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarImageViewWidth),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

    }
}

// MARK: - Preview

#if DEBUG

struct ProfileViewPreview: PreviewProvider {
    static var previews: some View {
        let view = ProfileViewImpl()
        return UIViewPreview(view)
            .previewDevice("iPhone 12")
            .previewLayout(.device)
    }
}

#endif

// Используется для отображения в превью Xcode

struct UIViewPreview<View: UIView>: UIViewRepresentable {
    
    private let view: View
    
    init(_ view: View) {
        self.view = view
    }
    
    func makeUIView(context: Context) -> View {
        return view
    }
    
    func updateUIView(_ uiView: View, context: Context) {
        
    }
}
