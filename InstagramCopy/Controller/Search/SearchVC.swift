//
//  SearchVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class SearchVC: UITableViewController {
    //MARK: - Properties
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    func setupView() {
        navigationItem.title = "Explore"
        
        tableView.register(ProfileUserCell.self, forCellReuseIdentifier: ProfileUserCell.reuseIdentifire)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
        fetchUserData()
    }

    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.reuseIdentifire, for: indexPath) as! ProfileUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userToLoad = users[indexPath.row]
        let vc = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = userToLoad
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK: - API
    func fetchUserData() {
        users.removeAll()
        tableView.separatorStyle = .none
        showProgressIndicator(view: self.view, title: "Wait...")
        USER_REF.observe(.childAdded) { (snapshot) in
            hideProgressIndicator(view: self.view)
            self.tableView.separatorStyle = .singleLine
            // get currente userID to subtract from search list
            guard let currendUid = Auth.auth().currentUser?.uid else { return }
            // uid
            let uid = snapshot.key
            //snapshot value cast as dictionary
            if uid != currendUid {
                guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
                //contruct user
                let user = User(uid: uid, dictionary: dictionary)
                // append user to data source
                self.users.append(user)
            }
            self.tableView.reloadData()
        }
    }
}
