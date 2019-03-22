//
//  HomeController.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-27.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import CoreLocation

class HomeController: UITableViewController, MessagingDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    let locationManager: CLLocationManager = CLLocationManager()
    let cellId = "cellId"
    
    //For bringing user to chat from push notifications
    var pushSender: User? {
        didSet {
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.user = pushSender
            navigationController?.pushViewController(chatLogController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        tableView?.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
        setupNavigationBar()
        fetchUser()
        fetchAllUsers()
        
        //GeoLocation Segment
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = .striderYellow()
        //Setup center image
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "yellowCommentIcon"))
        //Setup Right Image
        let button = UIBarButtonItem(image: #imageLiteral(resourceName: "yellowProfileIcon-1"), style: .plain, target: self, action: #selector(handleShowProfile))
        navigationItem.rightBarButtonItem = button
    }
    
    @objc func handleShowProfile() {
        let userProfile = UserDetailsController()
        self.navigationController?.pushViewController(userProfile, animated: true)
    }
    
   fileprivate func registerForNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
            
            if let err = err {
                print("Failed to request auth:", err)
                return
            }
            
            if granted {
                print("Auth granted.")
            } else {
                print("Auth denied")
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    //Code for messenger cells display
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
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
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timeStamp?.int32Value > message2.timeStamp?.int32Value
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = messages.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
            cell.profileImageView.image = #imageLiteral(resourceName: "dogeBuddy")
            let message = messages[indexPath.row]
            cell.message = message
            return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let message = messages[indexPath.row]
            isUserChat(message: message)
    }
    
    fileprivate func isUserChat(message: Message) {
        guard let chatPartnerId = message.chatPartnerId() else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
            let uid = chatPartnerId
            let user = User(uid: uid, dictionary: dictionary)
            self.showChatControllerForUser(user: user)
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    var currentUser: User?
    fileprivate func fetchUser() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.currentUser = user
            self.observeUserMessages(user: user)
        }
    }
    
    var users = [User]()
    func fetchAllUsers() {
        let ref = Database.database().reference().child("users")
        ref.observe(.value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String : Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                
                guard let userDictionary = value as? [String : Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.name.compare(u2.name) == .orderedAscending
            })
            self.tableView.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to delete chat:", err)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
            })
        }
    }
    
    //-------------------------------------------------------------------------------------------
    //Setup & Save User Location
    //-------------------------------------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        saveUserLocation(location: currentLocation)
    }
    
    func saveUserLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        let values = ["latitude" : latitude, "longitude" : longitude] as [String : Any]
        let ref = Database.database().reference().child("users").child(uid)
        ref.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to update user's location:", err)
            }
            print("Successfully updated user's location")
        }
    }
    
    //-------------------------------------------------------------------------------------------
    //Setup Bottom TabBar and Strider Button Logic
    //-------------------------------------------------------------------------------------------
    
    let striderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "StriderIcon"), for: .normal)
        button.addTarget(self, action: #selector(handleTapStrider), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        return button
    }()
    
    let striderCircleView: CustomImageView = {
        let cv = CustomImageView()
        cv.layer.cornerRadius = 90 / 2
        cv.backgroundColor = .white
        return cv
    }()

    override var inputAccessoryView: UIView? {
        get {
            let containerView = UIView()
            containerView.backgroundColor = UIColor(white: 0, alpha: 0.05)
            containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
            
            // Strider Button
            containerView.addSubview(striderCircleView)
            let circlePadding = (view.frame.width - (90)) / 2
            striderCircleView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 5, paddingLeft: circlePadding, paddingBottom: 5, paddingRight: circlePadding, width: 90, height: 90)
            
            containerView.addSubview(striderButton)
            let striderButtonPadding = (view.frame.width - 60) / 2
            striderButton.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 20, paddingLeft: striderButtonPadding, paddingBottom: 20, paddingRight: striderButtonPadding, width: 60, height: 60)
       
            return containerView
        }
    }
    
    var timer2: Timer?
    @objc func handleTapStrider() {
        striderButton.isEnabled = false
        registerForNotifications()
        startPulse()

        let fiveSeconds = 3
        timer2 = Timer.scheduledTimer(withTimeInterval: TimeInterval(fiveSeconds), repeats: false, block: { (timer) in
            self.striderButton.isEnabled = true
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.fetchUserWithUID(uid: uid) { (user) in
                self.compareLocations(currentUser: user)
            }
        })
    }
    
    func compareLocations(currentUser: User) {
        //Find current user's Location
        let currentUserLatitude = currentUser.latitude
        guard let currentLatitude = Double(currentUserLatitude) else { return }
        let currentUserLongitude = currentUser.longitude
        guard let currentLongitude = Double(currentUserLongitude) else { return }
        let currentUserLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        let savedRange = currentUser.range
        guard let rangeToDouble = Double(savedRange) else { return }
        let range = rangeToDouble * 1000

        for user in users {
        // Find all others user's Locations
            if let userLatitude = Double(user.latitude) {
                if let userLongitude = Double(user.longitude) {
                    let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
                    let distance = currentUserLocation.distance(from: userLocation)
                    if distance <= range {
                        self.matchedUsers.append(user)
                    }
                }
            }
        }
        self.matchedWithUser()
    }
    
    var matchedUsers = [User]()
    func matchedWithUser() {
        if matchedUsers.count > 0 {
            let count = self.matchedUsers.count
            let randomInt = Int(arc4random_uniform(UInt32(count)))
            let toUser = self.matchedUsers[randomInt]
            
            self.showChatControllerForUser(user: toUser)
        }
    }
    
    func startPulse() {
        let pulse = Pulsing(numberOfPulses: 5, radius: 150, position: CGPoint(x: (view.frame.width) / 2, y: (view.frame.height) - 50))
        pulse.animationDuration = 1
        pulse.backgroundColor = UIColor.googleRed().cgColor
        self.view.layer.insertSublayer(pulse, above: striderButton.layer)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
}

//-------------------------------------------------------------------------------------------
// This is for dealing with timstamp, message refreshing and Int32Values
//-------------------------------------------------------------------------------------------

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}




