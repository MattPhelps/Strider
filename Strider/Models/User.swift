//
//  User.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-22.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let username: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
    }
}

