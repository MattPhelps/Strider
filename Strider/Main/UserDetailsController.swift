//
//  UserDetailsController.swift
//  Strider
//
//  Created by Matt Phelps on 2018-08-17.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class UserDetailsController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var profilePicButton: CustomImageView = {
        let iv = CustomImageView()
        iv.layer.cornerRadius = 180 / 2
        iv.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChangePhoto))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let plusProfileImage: CustomImageView = {
        let iv = CustomImageView()
        iv.image = #imageLiteral(resourceName: "plusIcon")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    @objc func handleChangePhoto() {
        print("Presenting Image Picker...")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profilePicButton.image = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profilePicButton.image = originalImage
        }
        profilePicButton.layer.cornerRadius = profilePicButton.frame.width/2
        profilePicButton.layer.masksToBounds = true
        saveProfilePic()
        dismiss(animated: true, completion: nil)
    }
    
    func saveProfilePic() {
        guard let image = self.profilePicButton.image else { return }
        guard let uploadData = UIImageJPEGRepresentation(image, 0.2) else { return }
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference()
        let storageRefChild = storageRef.child("profile_images").child(filename)
        
        storageRefChild.putData(uploadData, metadata: nil, completion: { (metadata, err) in
            if let err = err {
                print("Unable to upload image into storage due to: \(err)")
            }
            storageRefChild.downloadURL(completion: { (url, err) in
                if let err = err {
                    print("Unable to retrieve URL due to error: \(err.localizedDescription)")
                    return
                }
                let profileImageUrl =  url?.absoluteString
                guard let uid = self.user?.uid else { return }
                let name = self.user?.name
                let values = ["name" : name, "uid" : uid, "profileImageUrl": profileImageUrl]
                
                Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
                  if let err = err {
                  print("Failed to save user info", err)
                  return
                }
                print("Successfully saved user info to db")
                })
            })
        })
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .darkBlue()
        label.textAlignment = .center
        return label
    }()
    
    let rangeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("?", for: .normal)
        button.setTitleColor(.darkBlue(), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 75 / 2
        button.backgroundColor = .googleRed()
        button.addTarget(self, action: #selector(handleChangeDistance), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeDistance() {
        let selectVC = UINavigationController(rootViewController: SelectNumberVC())
        selectVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        present(selectVC, animated: true, completion: nil)
    }
    
    lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "greyCogIcon"), for: .normal)
        button.addTarget(self, action: #selector(handleShowOptions), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    @objc func handleShowOptions() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Chat With Us", style: .default, handler: { (_) in
            let mattUID = "mrByyDLkeoPMnj48xwWN4rveMRz1"
            Database.fetchUserWithUID(uid: mattUID, completion: { (user) in
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.user = user
                self.navigationController?.pushViewController(chatLogController, animated: true)
            })
        }))
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let login = LoginController(collectionViewLayout: layout)
            self.present(login, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchUser()
        setupNavImages()
        view.addSubview(profilePicButton)
        profilePicButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 100, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 180, height: 180)
        profilePicButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(plusProfileImage)
        let pic = profilePicButton
        plusProfileImage.anchor(top: nil, left: nil, bottom: pic.bottomAnchor, right: pic.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 40, height: 40)
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: profilePicButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        
        let buttonPadding = (view.frame.width - 75) / 2
        view.addSubview(rangeButton)
        rangeButton.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: buttonPadding, paddingBottom: 0, paddingRight: buttonPadding, width: 75, height: 75)
        
        view.addSubview(optionsButton)
        let padding = (view.frame.width - 60) / 2
        optionsButton.anchor(top: rangeButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 36, paddingLeft:
            padding, paddingBottom: 0, paddingRight: padding, width: 60, height: 60)
        attemptReload()
    }
    
    var timer: Timer?
    fileprivate func attemptReload() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadPage), userInfo: nil, repeats: true)
    }
    
    @objc func handleReloadPage() {
       fetchUser()
    }
    
    var user: User?
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.nameLabel.text = user.name
            let profileImageUrl = user.profileImageUrl
            self.profilePicButton.loadImage(urlString: profileImageUrl)
            let title = user.range + "km"
            self.rangeButton.setTitle(title, for: .normal)
        }
    }
    
    func setupNavImages() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .striderYellow()
      // Setup Back Button as Home Button
        let homeImage = UIImage(named: "yellowCommentIcon")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backIndicatorImage = homeImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = homeImage
        navigationItem.leftItemsSupplementBackButton = true
        // Setup center image
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "yellowProfileIcon-1"))
    }
    
}
