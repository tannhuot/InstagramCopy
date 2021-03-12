//
//  ChatVC.swift
//  InstagramCopy
//
//  Created by Khouv Tannhuot on 7/3/21.
//

import UIKit
import Firebase

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    //MARK: - Properties
    var user: User?
    var messages = [Message]()
    
    lazy var containerView: UIView = {
       let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        v.addSubview(sendButton)
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: v.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 50, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
        
        v.addSubview(messageTextField)
        messageTextField.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        v.addSubview(separatorView)
        separatorView.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: nil, right: v.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return v
    }()
    
    let messageTextField: UITextField = {
       let tf = UITextField()
        tf.placeholder = "Enter message"
        return tf
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.addTarget(self, action: #selector(handleSentMessage), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigation()
        
        collectionView.backgroundColor = .white
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: ChatCell.reuseIdentifire)
        
        observeMessage()
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

//MARK: - UI Collection View
extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCell.reuseIdentifire, for: indexPath) as! ChatCell
        cell.message = messages[indexPath.row]
        
        configureMessage(cell: cell, message: messages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let messageText = message.messageText {
            height = estimateFrameForText(messageText).height + 20
        } /*else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }*/
        
        return CGSize(width: view.frame.width, height: height)
    }
}

//MARK: - Helpers
extension ChatViewController {
    func configureNavigation() {
        guard let user = user else { return }
        
        navigationItem.title = user.userName
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTap), for: .touchUpInside)
        
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButton
    }
    
    @objc private func handleInfoTap() {
        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    @objc private func handleSentMessage() {
        uploadMessageToServer()
        
        messageTextField.text = nil
    }
    
    @objc func handleKeyboardDidShow() {
        //scrollToBottom()
    }
    
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if let messageText = message.messageText {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(messageText).width + 32
            cell.frame.size.height = estimateFrameForText(messageText).height + 20
            //cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
            cell.bubbleView.backgroundColor  = UIColor.rgb(red: 0, green: 137, blue: 249)
        } /*else if let messageImageUrl = message.imageUrl {
            cell.bubbleWidthAnchor?.constant = 200
            cell.messageImageView.loadImage(with: messageImageUrl)
            //cell.messageImageView.isHidden = false
            cell.textView.isHidden = true
            cell.bubbleView.backgroundColor = .clear
        }
        
        if message.videoUrl != nil {
            guard let videoUrlString = message.videoUrl else { return }
            guard let videoUrl = URL(string: videoUrlString) else { return }
            
            player = AVPlayer(url: videoUrl)
            cell.player = player
            
            playerLayer = AVPlayerLayer(player: player)
            cell.playerLayer = playerLayer
            
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }*/
        
        if message.fromId == currentUid {
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
        } else {
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
}

//MARK: - API
extension ChatViewController {
    func uploadMessageToServer() {
        guard let messageText = messageTextField.text,
              let currentuid = Auth.auth().currentUser?.uid,
              let user = self.user
              else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValue = [ "creationDate": creationDate,
                             "fromId": currentuid,
                             "toId": user.uid,
                             "messageText": messageText
        ] as [String : Any]
        
        let messageRef = MESSAGE_REF.childByAutoId()
        messageRef.updateChildValues(messageValue)
        
        USER_MESSAGE_REF.child(currentuid).child(user.uid).updateChildValues(["\(messageRef.key ?? "")" : 1])
        
        USER_MESSAGE_REF.child(user.uid).child(currentuid).updateChildValues(["\(messageRef.key ?? "")" : 1])
    }
    
    func observeMessage() {
        guard let currentuid = Auth.auth().currentUser?.uid,
              let chatPartnerId = self.user?.uid
        else { return }
        
        USER_MESSAGE_REF.child(currentuid).child(chatPartnerId).observe(.childAdded) { (snapshot) in
            let messageId = snapshot.key
            
            self.fetchMessage(withMessageId: messageId)
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGE_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary =  snapshot.value as? Dictionary<String, Any> else { return }
            
            let message = Message(dictionary: dictionary)
            self.messages.append(message)
            self.collectionView.reloadData()
        }
    }
}
