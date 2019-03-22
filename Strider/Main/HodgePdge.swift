//
//  HodgePdge.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-30.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit

class ggg: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
         view.backgroundColor = .white
        
        setupLogoContainerView()
    }
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(
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
