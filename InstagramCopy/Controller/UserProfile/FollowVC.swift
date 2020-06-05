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
    enum ViewingMode: Int {
        case Following
        case Follower
        case Likes
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Follower
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    var viewingMode: ViewingMode!
    var isFromFollowing = true
    var uid: String?
    var users = [User]()
    var postID: String?
    // MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavTitle()
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
    //MARK: - Handlers
    func configureNavTitle() {
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .Following: navigationItem.title = "Following"
        case .Follower: navigationItem.title = "Followers"
        case .Likes: navigationItem.title = "Likes"
        }
    }
    //MARK: - API
    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        switch viewingMode {
        case .Follower: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
        }
    }
    func fetchUsers() {
        guard let ref = getDatabaseReference() else { return }
        guard let viewingMode = self.viewingMode else { return }
        switch viewingMode {
        case .Follower, .Following:
            guard let uid = self.uid else { return }
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
        case .Likes:
            guard let postID = self.postID else { return }
            ref.child(postID).observe(.childAdded) { (snapshot) in
                let uid = snapshot.key
                Database.fetchUser(with: uid) { (user) in
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
            cell.followButton.backgroundColor = .getActiveButtonColor
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
