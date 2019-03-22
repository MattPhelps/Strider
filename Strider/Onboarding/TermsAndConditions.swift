//
//  TermsAndConditions.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-30.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit

class TermsAndConditions: UIViewController {
    
    let termsLabel: UILabel = {
        let tl = UILabel()
        tl.font = UIFont.boldSystemFont(ofSize: 12)
        tl.textAlignment = .center
        tl.numberOfLines = 0
        tl.text = "By using Striderr, you agree to the following terms.\n Users engaging in any form of abuse or\n uploading objectionable content of any form deemed by Striderr will have their account\n deleted. This includes any nudity, harrassment,\n profanity, racism and anti-social behaviour."
        return tl
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue()
        button.layer.cornerRadius = 35
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    @objc func handleAccept() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let login = LoginController(collectionViewLayout: layout)
        present(login, animated: true, completion: nil)
        print("Showing Login Page")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(termsLabel)
        termsLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 240, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        view.addSubview(acceptButton)
        acceptButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 36, paddingBottom: 16, paddingRight: 36, width: 0, height: 70)
    }
}
