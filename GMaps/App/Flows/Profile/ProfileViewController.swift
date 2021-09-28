//
//  ProfileViewController.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.09.2021.
//

import UIKit
import AVFoundation
import Photos

class ProfileViewController: UIViewController {

    private var contentView: ProfileView {
        return self.view as! ProfileView
    }
    
    private let userManager: UserManager = UserManagerImpl()
    private lazy var imageManager: ImageManager = ImageManagerImpl(delegate: self)
    
    // MARK: - Life cycle
    
    override func loadView() {
        self.view = ProfileViewImpl()
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
    
    // MARK: - Private methods
    
    private func setup() {
        self.title = "Profile"
        contentView.avatarImageView.addGestureRecognizer(avatarTap)
        contentView.update(avatar: userManager.fetchAvatar()) 
    }
    
    func update(avatar image: UIImage?) {
        contentView.update(avatar: image)
    }
    
    private func save(avatar image: UIImage) {
        userManager.saveAvatar(image: image)
        contentView.update(avatar: image)
    }
    
    private lazy var avatarTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapForChangeImageForAvatar(_:)))
        return tap
    }()
    
    @objc private func didTapForChangeImageForAvatar(_ sender: UITapGestureRecognizer) {
        imageManager.showDialogForWorkingWithImages(title: "Аватар")
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        tabBarController?.tabBar.isHidden = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) {
            guard let image = self.extractImage(from: info) else { return }
            self.save(avatar: image)
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
