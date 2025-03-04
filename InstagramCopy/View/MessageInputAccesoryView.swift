//
//  MessageInputAccesoryView.swift
//  InstagramCopy
//
//  Created by dev229 on 12/3/21.
//

import UIKit

class MessageInputTextView: UITextView {
    // MARK: - Properties
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter message.."
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    @objc func handleInputTextChange() {
        placeholderLabel.isHidden = !self.text.isEmpty
    }
}


class MessageInputAccesoryView: UIView {
    // MARK: - Properties
    var delegate: MessageInputAccesoryViewDelegate?
    
    let messageInputTextView: MessageInputTextView = {
        let tv = MessageInputTextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        return tv
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadMessage), for: .touchUpInside)
        return button
    }()
    
    let uploadImageIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "upload_image_icon")
        return iv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        autoresizingMask = .flexibleHeight
        
        backgroundColor = .white
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
        
        addSubview(uploadImageIcon)
        uploadImageIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImage)))
        uploadImageIcon.isUserInteractionEnabled = true
        uploadImageIcon.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 44, height: 44)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: uploadImageIcon.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 4, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)
        separatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clearMessageTextView() {
        messageInputTextView.placeholderLabel.isHidden = false
        messageInputTextView.text = nil
    }
    
    // MARK: - Handlers
    
    @objc func handleUploadMessage() {
        guard let message = messageInputTextView.text else { return }
        delegate?.handleUploadMessage(message: message)
    }
    
    @objc func handleSelectImage() {
        delegate?.handleSelectImage()
    }
}

