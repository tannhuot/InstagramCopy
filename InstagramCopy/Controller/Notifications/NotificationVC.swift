//
//  NotificationVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class NotificationVC: UITableViewController {
    //MARK: - Properties
    var notifications = [Notification]()
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notifications"
        
        tableView.separatorColor = .clear
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseIdentifire)
        
        // fetch notification
        fetchNotification()

    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseIdentifire, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}
//MARK: - Handler
extension NotificationVC {
    @objc func handleSortNotification() {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        tableView.reloadData()
    }
    
    func handleReloadTable() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotification), userInfo: nil, repeats: false)
    }
}

//MARK: - Notifcaction Delegate Protocol
extension NotificationVC: NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            // Handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        }else{
            // Handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        navigationController?.pushViewController(feedController, animated: true)
    }
}

//MARK: - API
extension NotificationVC {
    func fetchNotification() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATION_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid) { (user) in
                // if notification for post
                if let postId = dictionary["postId"] as? String {
                    Database.fetchPost(with: postId) { (post) in
                        let notification = Notification(user: user, post: post, dictionary: dictionary)
                        self.notifications.append(notification)
                        self.handleReloadTable()
                    }
                }else{
                    let notification = Notification(user: user, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                }
            }
            
            NOTIFICATION_REF.child(currentUid).child(snapshot.key).child("checked").setValue(1)
        }
    }
}
