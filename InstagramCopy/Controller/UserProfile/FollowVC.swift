//
//  FollowVC.swift
//  InstagramCopy
//
//  Created by Huot on 12/3/19.
//

import UIKit
import Firebase

class FollowVC : UITableViewController {
    //MARK: - Properties
    var isFromFollowing = true
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromFollowing {
            navigationItem.title = "Following"
        }else{
            navigationItem.title = "Follower"
        }
        
        tableView.separatorStyle = .none
        tableView.register(ProfileUserCell.self, forCellReuseIdentifier: ProfileUserCell.reuseIdentifire)
        fetchUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    //MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.reuseIdentifire, for: indexPath) as! ProfileUserCell
        cell.delegate = self
        cell.isEnableFollowButton = true
        cell.user = self.users[indexPath.row]
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
    func fetchUsers() {
        guard let uid = self.uid else { return }
        var ref: DatabaseReference!
        if isFromFollowing{
            // fetch followings
            ref = USER_FOLLOWING_REF
        }else{
            // fetch followers
            ref = USER_FOLLOWER_REF
        }
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.forEach { (snapshot) in
                let userID = snapshot.key
                Database.fetchUser(with: userID) { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension FollowVC: ProfileUserCellDelegate {
    func handleFollowTapped(for cell: ProfileUserCell) {
        guard let user = cell.user else { return }
        if user.isFollowed {
            user.unfollow()
            // configue follow button
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = .getActiveButtonColor()
        }else{
            user.follow()
            // configue follow button
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
    }
    
}
