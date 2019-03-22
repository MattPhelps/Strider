//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var fromProfileImageUrl: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.fromProfileImageUrl = dictionary["fromProfileImageUrl"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timeStamp = dictionary["timeStamp"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
