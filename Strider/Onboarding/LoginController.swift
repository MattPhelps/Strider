//
//  SwipingController.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-26.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FBSDKLoginButtonDelegate{
    
    let cellId = "cellId"
    
    let pages = [
        Page(imageName: "StriderIcon", headerText: "Find Local Hackers", descriptionText: "Tap the Strider button and we'll find anyone within a 5km radius that wants to chat."),
        Page(imageName: "Unicorn", headerText: "Adjust Your Range", descriptionText: "Find people within 1km of you or as far away as 500km")
    ]
    
    override func viewDidLoad() {
        collectionView?.backgroundColor = .white
        collectionView?.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.isPagingEnabled = true
        setupFBButton()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        let page = pages[indexPath.item]
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height * 0.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //Setup Bottom TabBar and Button
    
    let facebookButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        //Set Button Title
        button.setTitle("LOG IN", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0.0)
        // Set Button Image
        let FBImage = UIImage(named: "ThumbsUp")
        button.setImage(FBImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -160, bottom: 0, right: 0)
        
        button.backgroundColor = .facebookBlue()
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return button
    }()
    
    let termsLabel: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms & Conditions", for: .normal)
        button.tintColor = .twitterBlue()
        button.addTarget(self, action: #selector(handleShowTerms), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowTerms() {
        let termsController = TermsAndConditions()
      present(termsController, animated: true, completion: nil)
    }
    
    func setupFBButton() {
        collectionView?.addSubview(termsLabel)
        collectionView?.addSubview(facebookButton)
        
        let paddingBottom = 0.035 * view.frame.height
        termsLabel.anchor(top: facebookButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: paddingBottom, paddingRight: 0, width: 0, height: 0)
    
        let fbButtonHeight = 0.086 * view.frame.height
        facebookButton.anchor(top: nil, left: view.leftAnchor, bottom: termsLabel.topAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 30, paddingBottom: 15, paddingRight: 30, width: (view.frame.width - 60), height: fbButtonHeight)
        facebookButton.layer.cornerRadius = (fbButtonHeight) / 2
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print("FB Login failed:", error ?? "")
                return
            }
            self.startSignUpAndSave()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of FB")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error:", error)
            return
        }
        startSignUpAndSave()
    }
    
    func startSignUpAndSave() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print("Failed to start graph request:", error ?? "")
                return
            }
            self.loginWithCredentials(credentials: credentials, result: result as Any)
        }
        presentHomeController()
    }
    
    func loginWithCredentials(credentials: AuthCredential, result: Any) {
        //This is what logs us in to Firebase
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something wrong with FB User:", error ?? "")
                return
            }
            //This saves user info to Firebase
            guard let uid = user?.uid else { return }
            let ref = Database.database().reference().child("users").child(uid)
            ref.updateChildValues(result as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to save user info into db:", err)
                    return
                }
            })
            self.saveFCMTokenAndRange()
            self.saveProfilePic()
            print("Successfully saved user info to Database.")
            print("Successfully logged in with user:", uid)
        })
    }
    
    func saveFCMTokenAndRange() {
        guard let fcmToken = Messaging.messaging().fcmToken else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let range = "5"
        let values = ["fcmToken" : fcmToken, "range" : range]
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print("Failed to save user info into db:", err)
                return
            }
        })
    }
    
    func saveProfilePic() {
        let image = #imageLiteral(resourceName: "dogeBuddy")
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
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let values = ["profileImageUrl": profileImageUrl]
                
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

    
    func presentHomeController() {
        let homeController = UINavigationController(rootViewController: HomeController())
        present(homeController, animated: true, completion: nil)
    }
    
}
