//
//  PageCell.swift
//  Strider
//
//  Created by Matt Phelps on 2018-07-26.
//  Copyright © 2018 Matt Phelps. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell {
    
    var page: Page? {
        didSet {
            setupPageContents()
        }
    }
    
    func setupPageContents() {
        guard let imageName = page?.imageName else { return }
        guard let headerText = page?.headerText else { return }
        guard let descriptionText = page?.descriptionText else { return }
        imageView.image = UIImage(named: imageName)
        
        let attributedText = NSMutableAttributedString(string: headerText, attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)])
        attributedText.append(NSAttributedString(string: "\n\n\(descriptionText)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.gray]))
        textView.attributedText = attributedText
        textView.textAlignment = .center
        
        //Which page pagecontrols should display is selected
        pageControls.currentPage = 0
        
        //Setup customizations for second page
        if imageName == "Unicorn" {
            pageControls.currentPage = 1
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupTextView()
        setupBottomControls()
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private func setupImageView() {
        addSubview(imageView)
        let imageSize = 0.5 * frame.height
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .center
        tv.isEditable = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    private func setupTextView() {
        addSubview(textView)
        textView.anchor(top: imageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 0)
    }
    
    private let pageControls: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 2
        pc.currentPageIndicatorTintColor = .googleRed()
        pc.transform = CGAffineTransform(scaleX: 2, y: 2)
        pc.pageIndicatorTintColor = .lightGray
        return pc
    }()
    
    func setupBottomControls() {
        addSubview(pageControls)
        let bottomPadding = 0.035 * 0.6 * frame.height
        pageControls.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: bottomPadding, paddingRight: 0, width: (frame.width / 3), height: 0)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
