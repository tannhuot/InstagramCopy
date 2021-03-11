//
//  NewMessageVC.swift
//  InstagramCopy
//
//  Created by Khouv Tannhuot on 7/3/21.
//

import UIKit
import Firebase

class NewMessageVC: UITableViewController {
    //MARK: - Properties
    var users = [User]()
    var messageVC: MessageVC?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: NewMessageCell.reuseIdentifire)
        
        fetchUsers()
    }
}

//MARK: - UI Table View
extension NewMessageVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewMessageCell.reuseIdentifire, for: indexPath) as! NewMessageCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [self] in
            let user = users[indexPath.row]
            messageVC?.showChatVC(forUser: user)
        }
    }
}

//MARK: - Helpers
extension NewMessageVC {
    func configureNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - API
extension NewMessageVC {
    func fetchUsers() {
        USER_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid) { [self] (user) in
                    users.append(user)
                    tableView.reloadData()
                }
            }
        }
    }
}
