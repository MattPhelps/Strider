//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase
import AudioToolbox


class MessageUserListController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, FriendsListHeaderDelegate {
    
    var friendsDelegate: FriendsListControllerDelegate?
    
    let cellId = "cellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        navigationItem.setHidesBackButton(true, animated: true)
        let nav = navigationController?.navigationBar
        
        nav?.addSubview(backButton)
        backButton.anchor(top: nav?.topAnchor, left: nav?.leftAnchor, bottom: nav?.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        nav?.addSubview(searchBar)
        searchBar.anchor(top: nav?.topAnchor, left: backButton.rightAnchor, bottom: nav?.bottomAnchor, right: nav?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView?.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(FriendsListHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
    }
    
    var isFriendsView = true
    
    func didChangeToFriendsView() {
        isFriendsView = true
        searchBar.text = ""
        cleanArrays()
        fetchFriendsList()
        collectionView?.reloadData()
    }
    
    func didChangeToSearchView() {
        isFriendsView = false
        searchBar.text = ""
        cleanArrays()
        fetchUsers()
        collectionView?.reloadData()
    }
    
    func cleanArrays() {
        users.removeAll()
        filteredUsers.removeAll()
        friendsList.removeAll()
        friends.removeAll()
        filteredFriends.removeAll()
    }
    
    var friendsList = [String]()
    fileprivate func fetchFriendsList() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("users").child(userId).child("friendsList")
        ref.observe(.value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String : Any] else { return }
            dictionaries.forEach({ (key, value) in
                self.friendsList.append(key)
            })
            self.fetchFriends()
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
    
    var filteredFriends = [User]()
    var friends = [User]()
    fileprivate func fetchFriends() {
        let ref = Database.database().reference().child("users")
        ref.observe(.value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String : Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let userDictionary = value as? [String : Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                for invite in self.friendsList {
                    if invite == user.uid {
                        self.friends.append(user)
                    }
                }
            })
            self.filteredFriends = self.friends
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.barTintColor = .gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return sb
    }()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if isFriendsView {
            if searchText.isEmpty {
                filteredFriends = friends
            } else {
                self.filteredFriends = self.friends.filter { (user) -> Bool in
                    return user.username.lowercased().contains(searchText.lowercased())
                }
            }
            self.collectionView?.reloadData()
        } else {
            if searchText.isEmpty {
                filteredUsers = users
            } else {
                self.filteredUsers = self.users.filter { (user) -> Bool in
                    return user.username.lowercased().contains(searchText.lowercased())
                }
            }
            self.collectionView?.reloadData()
        }
    }
    
    var filteredUsers = [User]()
    var users = [User]()
    fileprivate func fetchUsers() {
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
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
    
    var messengerHomeController: MessengerHomeController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) {
            if self.isFriendsView {
                let user = self.filteredFriends[indexPath.item]
                self.messengerHomeController?.showChatControllerForUser(user: user)
            } else {
                let user = self.filteredUsers[indexPath.item]
                self.messengerHomeController?.showChatControllerForUser(user: user)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isFriendsView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
            if indexPath.item < friends.count {
                cell.user = filteredFriends[indexPath.item]
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
            if indexPath.item < filteredUsers.count {
                cell.user = filteredUsers[indexPath.item]
            }
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFriendsView {
            return filteredFriends.count
        } else {
            return filteredUsers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! FriendsListHeader
        header.delegate = self
        self.friendsDelegate = header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 45)
    }
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = .mainBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleClickBack), for: .touchUpInside)
        return button
    }()
    
    @objc func handleClickBack() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cleanArrays()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cleanArrays()
        fetchFriendsList()
        fetchUsers()
    }
}

