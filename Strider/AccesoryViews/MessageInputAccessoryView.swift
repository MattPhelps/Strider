//  Created by Matt Phelps on 11/28/17.
//  Copyright © 2017 Contendr. All rights reserved.

import UIKit

protocol MessageInputAccessoryViewDelegate {
    func didSubmit(for message: String)
    func showUserOptions()
}

class MessageInputAccessoryView: UIView {
    
    var delegate: MessageInputAccessoryViewDelegate?
    
    func clearMessageTextField() {
        messageTextView.text = nil
        messageTextView.showPlaceholderLabel()
    }
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "yellowSendButton"), for: .normal)
        button.tintColor = .striderYellow()
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
   
    @objc func handleSend() {
        guard let messageText = messageTextView.text else { return }
        if messageTextView.text.count > 0 {
             delegate?.didSubmit(for: messageText)
        }
    }
    
    lazy var messageTextView: InputTextView = {
        let tv = InputTextView()
        tv.messageText = "Write a message..."
        tv.isScrollEnabled = false
        tv.font = UIFont.systemFont(ofSize: 18)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.layer.cornerRadius = 20
        return tv
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "elipsisIcon"), for: .normal)
        button.addTarget(self, action: #selector(handleUserOptions), for: .touchUpInside)
        return button
    }()
    
    @objc func handleUserOptions() {
        delegate?.showUserOptions()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoresizingMask = .flexibleHeight
        backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 30, height: 30)
        
        addSubview(optionsButton)
        optionsButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 17, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 6, height: 20)
        
        addSubview(messageTextView)
        messageTextView.anchor(top: topAnchor, left: optionsButton.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
