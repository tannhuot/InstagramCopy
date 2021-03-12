//
//  MessageVC.swift
//  InstagramCopy
//
//  Created by Khouv Tannhuot on 7/3/21.
//

import UIKit
import Firebase

class MessageVC: UITableViewController {
    //MARK: - Properties
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifire)
        
        fetchMessages()
    }
}

//MARK: - UI Table View
extension MessageVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifire, for: indexPath) as! MessageCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let msg = messages[indexPath.row]
        let chatPartId = msg.getChatPartnerId()
        Database.fetchUser(with: chatPartId) { (user) in
            self.showChatVC(forUser: user)
        }
    }
}

//MARK: - Helpers
extension MessageVC {
    func configureNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
    
    @objc private func handleNewMessage() {
        let vc = NewMessageVC()
        vc.messageVC = self
        let navVC = UINavigationController(rootViewController: vc)
        fullScreen(viewController: navVC)
        present(navVC, animated: true, completion: nil)
    }
    
    func showChatVC(forUser user: User) {
        let vc = ChatViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - API
extension MessageVC {
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.messages.removeAll()
        self.messageDictionary.removeAll()
        self.tableView.reloadData()
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { (snapshot) in
                let messaageId = snapshot.key
                
                self.fetchMessage(withMessageId: messaageId)
            }
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary =  snapshot.value as? Dictionary<String, Any> else { return }
            
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            self.messageDictionary[chatPartnerId] = message
            self.messages = Array(self.messageDictionary.values)
            self.tableView.reloadData()
        }
    }
}
