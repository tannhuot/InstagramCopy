//
//  MessageVC.swift
//  InstagramCopy
//
//  Created by Khouv Tannhuot on 7/3/21.
//

import UIKit

class MessageVC: UITableViewController {
    //MARK: - Properties
    var messages = [Message]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifire)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifire, for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
