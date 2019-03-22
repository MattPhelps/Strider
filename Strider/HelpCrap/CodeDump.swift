//
//  CodeDump.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-26.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import Foundation

/*   func setupGoogleSignInButton() {
 let googleButton = GIDSignInButton()
 view.addSubview(googleButton)
 googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width, height: 50)
 
 GIDSignIn.sharedInstance().uiDelegate = self
 } */

/*    func setupFBLoginButton() {
 let loginButton = FBSDKLoginButton()
 view.addSubview(loginButton)
 loginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width, height: 50)
 //loginButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 200, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: (view.frame.width - 32), height: 0)
 
 loginButton.delegate = self
 loginButton.readPermissions = ["email", "public_profile"]
 } */


//   setupGoogleSignInButton()

//  setupFBLoginButton()

/*    func setupCustomGoogleButton() {
 let googleButton = UIButton(type: .system)
 googleButton.backgroundColor = .googleRed()
 googleButton.setTitle("Google", for: .normal)
 googleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
 googleButton.setTitleColor(.white, for: .normal)
 googleButton.layer.cornerRadius = (view.frame.width / 10)
 //    googleButton.layer.borderColor = UIColor.black.cgColor
 //      googleButton.layer.borderWidth = 2
 googleButton.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
 view.addSubview(googleButton)
 googleButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 205, paddingRight: 20, width: view.frame.width - 40, height: 75)
 } */


/*   func setupCustomFBButton() {
 let customFBButton = UIButton(type: .system)
 customFBButton.backgroundColor = .facebookBlue()
 customFBButton.setTitle("Facebook", for: .normal)
 customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
 customFBButton.setTitleColor(.white, for: .normal)
 customFBButton.layer.cornerRadius = (view.frame.width / 10)
 customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
 view.addSubview(customFBButton)
 customFBButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.width - 40, height: 75)
 } */

//        setupCustomFBButton()
//       setupCustomGoogleButton()


//     let statusBarBackgroundView = UIView()
//   statusBarBackgroundView.backgroundColor = .googleRed()

/*     collectionView?.addSubview(statusBarBackgroundView)
 collectionView?.addConstraintsWithFormat("H:|[v0]|", views: statusBarBackgroundView)
 collectionView?.addConstraintsWithFormat("V:|[v0(20)]", views: statusBarBackgroundView)
 */


/*      alertController.addAction(UIAlertAction(title: "Edit Profile", style: .default, handler: { (_) in
 
 }))*/

/*   @objc func handleNewMessage() {
 let newMessageController = NewMessageController()
 newMessageController.messengerHomeController = self
 let navController = UINavigationController(rootViewController: newMessageController)
 present(navController, animated: true, completion: nil)
 } */

/* func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    print("Logged out of FB")
}

func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    if error != nil {
        print("Error:", error)
        return
    }
    startSignUpAndSave()
} */


/* let googleButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .googleRed()
    button.layer.cornerRadius = 36
    button.tintColor = .white
    button.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
    // Button Title
    button.setTitle("Google", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    button.setTitleColor(.white, for: .normal)
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0.0)
    //Button Image
    let googleImage = UIImage(named: "GoogleG")
    button.setImage(googleImage, for: .normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -180, bottom: 0, right: 0)
    return button
}()

@objc func handleCustomGoogleSignIn() {
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().signIn()
} */

/*
//Google
GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
GIDSignIn.sharedInstance().delegate = self

return true
}

func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    //First Login to Google
    if let err = error {
        print("Failed to login to Google;", err)
    }
    print("Successfully logged into Google:", user ?? "")
    
    /*   let name = "\(user.profile.givenName) \(user.profile.familyName)"
     let email = user.profile.email
     guard let id = user.userID else { return }
     */
    guard let idToken = user.authentication.idToken else { return }
    guard let accessToken = user.authentication.accessToken else { return }
    let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    
    //Sign In & Authorise to firebase with Google credentials
    Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
        if let err = error {
            print("Failed to authenticate with google:", err)
            return
        }
        print("Successfully logged in with Google:")//, uid)
        self.presentSwipingController()
    }
}
 */
/*

func presentSwipingController() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let swipingController = SwipingController(collectionViewLayout: layout)
    self.window?.rootViewController = swipingController
} */

/*
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    
    GIDSignIn.sharedInstance().handle(url,
                                      sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                      annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    return handled
} */




//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Brian Voong on 3/24/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//
/**
 import UIKit
 import Firebase
 import FBSDKLoginKit
 import GoogleSignIn
 
 class LoginController: UIViewController, FBSDKLoginButtonDelegate {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 navigationController?.isNavigationBarHidden = true
 view.backgroundColor = .white
 setupLogoContainerView()
 setupSignUpLabel()
 setupTermsLabel()
 }
 
 let logoContainerView: UIView = {
 let view = UIView()
 let logoImageView = UIImageView(image: #imageLiteral(resourceName: "StriderTitle"))
 view.addSubview(logoImageView)
 logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
 logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
 logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
 logoImageView.contentMode = .scaleToFill
 return view
 }()
 
 func setupLogoContainerView() {
 view.addSubview(logoContainerView)
 logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
 }
 
 
 
 
 }
 
 func observeUserMessages(user: User) {
 let uid = user.uid
 
 let ref = Database.database().reference().child("user-messages").child(uid)
 ref.observe(.childAdded, with: { (snapshot) in
 
 let userId = snapshot.key
 Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
 
 let messageId = snapshot.key
 self.fetchMessageWithMessageId(messageId)
 
 }, withCancel: nil)
 
 }, withCancel: nil)
 ref.observe(.childRemoved, with: { (snapshot) in
 self.messagesDictionary.removeValue(forKey: snapshot.key)
 self.attemptReloadOfTable()
 }, withCancel: nil)
 }
´
 
 {
 /* Visit https://firebase.google.com/docs/database/security to learn more about security rules. */
 "rules": {
 "users": {
 "$uid": {
 ".read": "$uid === auth.uid",
 ".write": "$uid === auth.uid"
 }
 }
 }
 }

 */



import UIKit
/*
 protocol ButtonAccessoryViewDelegate {
 func didTap()
 }
 
 class ButtonAccessoryView: UIView {
 
 var delegate: ButtonAccessoryViewDelegate?
 
 let striderButton: UIButton = {
 let button = UIButton(type: .system)
 button.setImage(#imageLiteral(resourceName: "StriderIcon"), for: .normal)
 button.tintColor = .white
 button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
 return button
 }()
 
 @objc func handleTap() {
 delegate?.didTap()
 }
 
 override init(frame: CGRect) {
 super.init(frame: frame)
 autoresizingMask = .flexibleHeight
 backgroundColor = .white
 
 addSubview(striderButton)
 striderButton.anchor(top: topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
 }
 
 override var intrinsicContentSize: CGSize {
 return .zero
 }
 
 required init?(coder aDecoder: NSCoder) {
 fatalError("init(coder:) has not been implemented")
 }
 } */

//      attemptRegisterForNotifications(application: application)

/*   private func attemptRegisterForNotifications(application: UIApplication) {
 print("Attempting to register for APNS...")
 
 Messaging.messaging().delegate = self
 UNUserNotificationCenter.current().delegate = self
 
 // User notification authorisation
 let options: UNAuthorizationOptions = [.alert, .badge, .sound]
 UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
 if let err = err {
 print("Failed to request authorization:", err)
 return
 }
 if granted {
 print("Auth granted.")
 } else {
 print("Auth denies.")
 }
 }
 application.registerForRemoteNotifications()
 } */

/*
 func applicationWillResignActive(_ application: UIApplication) {
 // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
 }
 
 func applicationDidEnterBackground(_ application: UIApplication) {
 // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
 // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 }
 
 func applicationWillEnterForeground(_ application: UIApplication) {
 // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
 }
 
 func applicationDidBecomeActive(_ application: UIApplication) {
 // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 }
 
 func applicationWillTerminate(_ application: UIApplication) {
 // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
 } */

/*    func setupUserBumps() {
 var bumpsImage: UIImage?
 guard let uid = message?.chatPartnerId() else { return }
 Database.fetchUserWithUID(uid: uid) { (user) in
 let count = user.bumps
 if count == "0" {
 bumpsImage = #imageLiteral(resourceName: "broccoli")
 } else if count == "1" {
 bumpsImage = #imageLiteral(resourceName: "mushroom")
 } else if count == "2" || count == "3" || count == "4" {
 bumpsImage = #imageLiteral(resourceName: "cheese")
 } else if count == "5" || count == "6" || count == "7" || count == "8" || count == "9" {
 bumpsImage = #imageLiteral(resourceName: "strawberry")
 } else if count == "10" || count == "11" || count == "12" || count == "13" || count == "14" || count == "15" || count == "16" || count == "17" || count == "18" || count == "19" {
 bumpsImage = #imageLiteral(resourceName: "cookie")
 } else if count == "20" || count == "21" || count == "22" || count == "23" || count == "24" || count == "25" || count == "26" || count == "27" || count == "28" || count == "29" || count == "30" || count == "31" || count == "32" || count == "33" || count == "34" || count == "35" || count == "36" || count == "37" || count == "38" || count == "39" || count == "40" || count == "41" || count == "42" || count == "43" || count == "44" || count == "45" || count == "46" || count == "47" || count == "48" || count == "49" {
 bumpsImage = #imageLiteral(resourceName: "donut")
 } else if count == "50" {
 bumpsImage = #imageLiteral(resourceName: "lollipop")
 } else {
 bumpsImage = #imageLiteral(resourceName: "broccoli")
 }
 self.bumpImageView.image = bumpsImage
 }
 } */

let bumpImageView: CustomImageView = {
    let imageView = CustomImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.masksToBounds = true
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
}()

func setupUserBumps() {
    var bumpsImage: UIImage?
    guard let count = user?.bumps else { return }
    
    if count == "0" {
        bumpsImage = #imageLiteral(resourceName: "broccoli")
    } else if count == "1" {
        bumpsImage = #imageLiteral(resourceName: "mushroom")
    } else if count == "2" || count == "3" || count == "4" {
        bumpsImage = #imageLiteral(resourceName: "cheese")
    } else if count == "5" || count == "6" || count == "7" || count == "8" || count == "9" {
        bumpsImage = #imageLiteral(resourceName: "strawberry")
    } else if count == "10" || count == "11" || count == "12" || count == "13" || count == "14" || count == "15" || count == "16" || count == "17" || count == "18" || count == "19" {
        bumpsImage = #imageLiteral(resourceName: "cookie")
    } else if count == "20" || count == "21" || count == "22" || count == "23" || count == "24" || count == "25" || count == "26" || count == "27" || count == "28" || count == "29" || count == "30" || count == "31" || count == "32" || count == "33" || count == "34" || count == "35" || count == "36" || count == "37" || count == "38" || count == "39" || count == "40" || count == "41" || count == "42" || count == "43" || count == "44" || count == "45" || count == "46" || count == "47" || count == "48" || count == "49" {
        bumpsImage = #imageLiteral(resourceName: "donut")
    } else if count == "50" {
        bumpsImage = #imageLiteral(resourceName: "lollipop")
    } else {
        bumpsImage = #imageLiteral(resourceName: "broccoli")
    }
    let button = UIBarButtonItem(image: bumpsImage, style: .plain, target: self, action: #selector(handleBump))
    navigationItem.rightBarButtonItem = button
}

@objc func handleBump() {
    guard let uid = self.user?.uid else { return }
    guard let currentUserId = Auth.auth().currentUser?.uid else { return }
    let values = [currentUserId : 1]
    
    Database.database().reference().child("bumps").child(uid).updateChildValues(values) { (err, _) in
        if let err = err {
            print("Failed to bump post", err)
            return
        }
        print("Successfully bumped post!")
        self.fetchUserBumpCount()
    }
    bumpSound()
}

func bumpSound() {
    let soundID: SystemSoundID = 1003
    AudioServicesPlayAlertSoundWithCompletion(soundID, nil)
}


var count: String?
func fetchUserBumpCount() {
    guard let uid = user?.uid else { return }
    let ref = Database.database().reference().child("bumps").child(uid)
    ref.observe(.value, with: { (snapshot) in
        let countString = String(snapshot.childrenCount)
        self.count = countString
        self.collectionView?.reloadData()
        self.updateUserBumpCount()
    }) { (err) in
        print("Failed to fetch users for search:", err)
    }
}

func updateUserBumpCount() {
    guard let uid = user?.uid else { return }
    let values = ["bumps" : self.count]
    
    Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (err, ref) in
        if let err = err {
            print("Failed to save user info", err)
            return
        }
        print("Successfully saved user info to db")
    })
}

var count: String? {
    didSet {
        setupUserBumpImage()
    }
}

func setupUserBumpImage() {
    var bumpsImage: UIImage?
    
    if count == "0" {
        bumpsImage = #imageLiteral(resourceName: "broccoli")
    } else if count == "1" {
        bumpsImage = #imageLiteral(resourceName: "mushroom")
    } else if count == "2" || count == "3" || count == "4" {
        bumpsImage = #imageLiteral(resourceName: "cheese")
    } else if count == "5" || count == "6" || count == "7" || count == "8" || count == "9" {
        bumpsImage = #imageLiteral(resourceName: "strawberry")
    } else if count == "10" || count == "11" || count == "12" || count == "13" || count == "14" || count == "15" || count == "16" || count == "17" || count == "18" || count == "19" {
        bumpsImage = #imageLiteral(resourceName: "cookie")
    } else if count == "20" || count == "21" || count == "22" || count == "23" || count == "24" || count == "25" || count == "26" || count == "27" || count == "28" || count == "29" || count == "30" || count == "31" || count == "32" || count == "33" || count == "34" || count == "35" || count == "36" || count == "37" || count == "38" || count == "39" || count == "40" || count == "41" || count == "42" || count == "43" || count == "44" || count == "45" || count == "46" || count == "47" || count == "48" || count == "49" {
        bumpsImage = #imageLiteral(resourceName: "donut")
    } else if count == "50" {
        bumpsImage = #imageLiteral(resourceName: "lollipop")
    } else {
        bumpsImage = #imageLiteral(resourceName: "broccoli")
    }
    bumpsButton.setImage(bumpsImage, for: .normal)
}



/*   // 1. user enter region
 func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
 print("enter \(region.identifier)")
 }
 
 // 2. user exit region
 func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
 print("exit \(region.identifier)")
 } */

/*     let latitude = currentLocation.coordinate.latitude
 let longitude = currentLocation.coordinate.longitude
 let userLocation = CLLocationCoordinate2DMake(latitude, longitude)
 let geoFenceRegion: CLCircularRegion = CLCircularRegion(center: userLocation, radius: 5000, identifier: userLocationId)
 locationManager.startMonitoring(for: geoFenceRegion) */

func sendMatchMessageToUser(toUser: User) {
    let ref = Database.database().reference().child("messages")
    let childRef = ref.childByAutoId()
    let toId = toUser.uid
    let message = "You're not that far away, are you working on any side-projects?"
    let properties = ["text": message] as [String : AnyObject]
    guard let fromId = Auth.auth().currentUser?.uid else { return }
    let timeStamp = Int(Date().timeIntervalSince1970)
    let fromProfileImageUrl = self.currentUser?.profileImageUrl
    
    var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timeStamp": timeStamp as AnyObject, "fromProfileImageUrl" : fromProfileImageUrl as AnyObject]
    
    //append properties dictionary onto values somehow??
    //key $0, value $1
    properties.forEach({values[$0] = $1})
    
    childRef.updateChildValues(values) { (error, ref) in
        if error != nil {
            print(error!)
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
        
        let messageId = childRef.key
        userMessagesRef.updateChildValues([messageId: 1])
        
        let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
        recipientUserMessagesRef.updateChildValues([messageId: 1])
    }
    
}
