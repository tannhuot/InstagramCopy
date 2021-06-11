//
//  FeedVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var navTitle = ""
    var logoutDelegate: logoutDelegate?
    var currentKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: FeedCell.reuseIdentifier)
        // Configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        configureNavBar()
        if !viewSinglePost {
            fetchPosts()
        }
        updateUserFeeds()
    }
    // MARK: UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        // 8 is come from padding of profileImageView top and bottom, 40 is profileImageViewHeight, 50 is stackView height, 60 is for like, comment and caption label
        let height = width + 8 + 40 + 8 + 50 + 60
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewSinglePost {
            return 1
        }
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCell.reuseIdentifier, for: indexPath) as! FeedCell
        if viewSinglePost {
            if let post = self.post{
                cell.post = post
            }
        }else{
            cell.post = self.posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    // MARK: - Handlers
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    @objc func handleShowMessage() {
        let vc = MessageVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    func configureNavBar() {
        if !viewSinglePost {
            navTitle = "Feed"
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(hanleLogout))
        }
        navigationItem.title = navTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleShowMessage))
        
    }
    
    @objc func hanleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                fullScreen(viewController: navController)
                
                self.logoutDelegate?.didLogout()
                
                self.present(navController, animated: true, completion: nil)
            }catch{
                print("Failed to sign out")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - API
    func updateUserFeeds() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUserID = snapshot.key
            USER_POSTS_REF.child(followingUserID).observe(.childAdded) { (snapshot) in
                let postId = snapshot.key
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
            }
        }
        
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
    }
    
    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if let key = currentKey {
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: key).queryLimited(toLast: 6).observeSingleEvent(of: .value) { [self](snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObj = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObj.forEach { (snapshot) in
                    let postId = snapshot.key
                    
                    if postId != currentKey {
                        fetchPost(withPostId: postId)
                    }
                }
                
                currentKey = first.key
            }
        } else {
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { [self](snapshot) in
                collectionView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObj = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObj.forEach { (snapshot) in
                    let postId = snapshot.key
                    fetchPost(withPostId: postId)
                }
                
                currentKey = first.key
            }
        }
    }
    
    func fetchPost(withPostId postId: String) {
        Database.fetchPost(with: postId) { [self](post) in
            posts.append(post)
            posts.sort { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            }
            collectionView.reloadData()
        }
    }
}

extension FeedVC: FeedCellDelegate {
    // User Name Tapped
    func handleUserNameTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let vc = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.user = post.user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Option Tapped
    func handleOptionTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        
        let alertController = UIAlertController(title: "Option", message: nil, preferredStyle: .actionSheet)
        
        if post.ownerUid == Auth.auth().currentUser?.uid {
            alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
                // Handle Edit Post
            }))
            
            alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { [self](_) in
                // Handle Delete Post
                post.deletePost()
                
                if !viewSinglePost {
                    handleRefresh()
                } else {
                    navigationController?.popViewController(animated: true)
                }
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Like Tapped
    func handleLikeTapped(for cell: FeedCell, isDoubleTab: Bool) {
        guard let post = cell.post else { return }
        if post.didLike {
            // Handle Unlike Post
            if isDoubleTab {
                return
            }
            post.adjustLikes(addLike: false) { (likes) in
                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                if likes > 1 {
                    cell.likeLabel.text = "\(likes) likes"
                }else{
                    cell.likeLabel.text = "\(likes) like"
                }
            }
        }else{
            // Handle Like Post
            post.adjustLikes(addLike: true) { (likes) in
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
                if likes > 1 {
                    cell.likeLabel.text = "\(likes) likes"
                }else{
                    cell.likeLabel.text = "\(likes) like"
                }
            }
        }
        if post.likes > 1 {
            cell.likeLabel.text = "\(post.likes) likes"
        }else{
            cell.likeLabel.text = "\(post.likes) like"
        }
        
    }
    
    // Comment Tapped
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let vc = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.post = post
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Configure Like button
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let post = cell.post else { return }
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(post.postID) {
                post.didLike = true
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
            }
        }
    }
    
    // handle likeLabel Tapped
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else { return }
        
        let vc = FollowVC()
        vc.viewingMode = FollowVC.ViewingMode(index: 2)
        vc.postID = post.postID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // handle message tapped
    func handleMessageTapped(for cell: FeedCell) {
        dialogOneButton("", "not yet implement", self) { (_) in
            print("ok")
        }
    }
    
    // handle bookmark tapped
    func handleBookMarkTapped(for cell: FeedCell) {
        dialogOneButton("", "not yet implement", self) { (_) in
            print("ok")
        }
    }
}
