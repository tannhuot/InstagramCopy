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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
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
        
    }
    
    @objc private func handleSentMessage() {
        uploadMessageToServer()
        
        messageTextField.text = nil
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
