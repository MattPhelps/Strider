//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase
import MobileCoreServices
import UserNotifications
import AudioToolbox

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, MessageInputAccessoryViewDelegate, UNUserNotificationCenterDelegate {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            fetchUser()
            observeMessages()
        }
    }
    
    var currentUser: User?
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.currentUser = user
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        setupNavigationBar()
        setupKeyboardObservers()
        
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .striderYellow()
        navigationController?.navigationBar.isTranslucent = false
        UINavigationBar.appearance().barTintColor = .facebookBlue()
        // Setup Back Button as Home Button
        let homeImage = UIImage(named: "yellowCommentIcon")
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backIndicatorImage = homeImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = homeImage
        navigationItem.leftItemsSupplementBackButton = true
        //Setup user's name center label
        let titleLabel = UILabel()
        titleLabel.text = user?.name
        titleLabel.textColor = .striderYellow()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    @objc func showUserOptions() {
        print("showing user options")
        guard let uid = self.user?.uid else { return }
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let values = [currentUserId : 1]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Report User", style: .default, handler: { (_) in
            
            Database.database().reference().child("reportedUsers").child(uid).updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to report user", err)
                    return
                }
                print("Successfully reported user!")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Block User", style: .default, handler: { (_) in
        
            Database.database().reference().child("blockRequests").child(uid).updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to block user", err)
                    return
                }
                print("Successfully block user!")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
 
    lazy var inputContainerView: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let messageInputAccessoryView = MessageInputAccessoryView(frame: frame)
        messageInputAccessoryView.delegate = self
        return messageInputAccessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    func didSubmit(for message: String) {
        let properties = ["text": message]
        sendMessageWithProperties(properties as [String : AnyObject])
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        setupCell(cell, message: message)
        
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        }
        return cell
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing
            cell.bubbleView.backgroundColor = .googleRed()
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            if let profileImageUrl = self.user?.profileImageUrl {
               cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            } else {
                cell.profileImageView.image = #imageLiteral(resourceName: "profileIcon")
            }
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        guard let toId = user?.uid else { return }
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        let timeStamp = Int(Date().timeIntervalSince1970)
        let fromProfileImageUrl = user?.profileImageUrl
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timeStamp": timeStamp as AnyObject, "fromProfileImageUrl" : fromProfileImageUrl as AnyObject]
        
        //append properties dictionary onto values somehow??
        //key $0, value $1
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputContainerView.clearMessageTextField()
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
}
