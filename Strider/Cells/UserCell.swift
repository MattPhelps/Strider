//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupForUser()
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timeStamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "               d MMM"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    fileprivate func setupForUser() {
        guard let id = message?.chatPartnerId() else { return }
        let ref = Database.database().reference().child("users").child(id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.textLabel?.text = dictionary["name"] as? String
                
                if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                    self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                }
            }
        }, withCancel: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 104, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        textLabel?.textColor = .darkBlue()
        
        detailTextLabel?.frame = CGRect(x: 104, y: detailTextLabel!.frame.origin.y + 2, width: frame.width - (170), height: detailTextLabel!.frame.height)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        detailTextLabel?.textColor = UIColor.darkGray
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.image = #imageLiteral(resourceName: "dogeBuddy")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = (104 - (12 * 2)) / 2
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
