//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase
/*
class NewMessageController: UITableViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        setupNavigationBar()
        fetchUsers()
    }
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search Users..."
        sb.barTintColor = .gray
        sb.delegate = self
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        return sb
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.tintColor = UIColor.facebookBlue()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleClickBack), for: .touchUpInside)
        return button
    }()
    
    @objc func handleClickBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavigationBar() {
        navigationItem.setHidesBackButton(true, animated: true)
        let nav = navigationController?.navigationBar
        
        nav?.addSubview(backButton)
        backButton.anchor(top: nav?.topAnchor, left: nav?.leftAnchor, bottom: nav?.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        nav?.addSubview(searchBar)
        searchBar.anchor(top: nav?.topAnchor, left: backButton.rightAnchor, bottom: nav?.bottomAnchor, right: nav?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
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
            self.tableView.reloadData()
        }) { (err) in
            print("Failed to fetch users for search:", err)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            self.filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = user.username
        
        let profileImageUrl = user.profileImageUrl
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.isHidden = false
        searchBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        backButton.isHidden = true
        searchBar.isHidden = true
    }
    
    var messengerHomeController: MessengerHomeController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.filteredUsers[indexPath.row]
            self.messengerHomeController?.showChatControllerForUser(user: user)
        }
    }
}
*/



