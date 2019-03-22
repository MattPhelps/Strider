//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase

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

class MessengerHomeController: UITableViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
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
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
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
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messengerHomeController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    var user: User?
    fileprivate func fetchUser() {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let message = self.messages[indexPath.row]
        if message.compId == nil {
        return true
        } else {
        return false
        }
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
    
}
 
