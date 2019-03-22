//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit

class InputTextView: UITextView {
    
    var messageText: String? {
        didSet {
            guard let message = self.messageText else { return }
            placeholderLabel.text = message
        }
    }
    
    fileprivate let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        return label
    }()
    
    func showPlaceholderLabel() {
        placeholderLabel.isHidden = false
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: .UITextViewTextDidChange, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
