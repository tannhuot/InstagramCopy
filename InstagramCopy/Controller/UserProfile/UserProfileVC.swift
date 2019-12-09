//
//  UserProfileVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let ProfileHeaderReuseIdentifier = "ProfileHeaderCell"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    var user: User?
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white

        // Register cell classes
        collectionView!.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderReuseIdentifier)
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: PostCell.reuseIndentifier)
        
        
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user == nil {
            fetchCurrentUserData()
        }else{
            navigationItem.title = user?.name
        }
    }

    // MARK: - UICollectionView FlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 3)/3, height: (view.frame.width - 2)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - UICollectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderReuseIdentifier, for: indexPath) as! ProfileHeaderCell
        // set user in header
        header.user = user
        // set delegate
        header.delegage = self
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIndentifier, for: indexPath) as! PostCell
        cell.post = posts[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        vc.viewSinglePost = true
        vc.post = posts[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: - API
    func fetchCurrentUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        collectionView.isHidden = true
        showProgressIndicator(view: self.view, title: "Wait...")
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            hideProgressIndicator(view: self.view)
            self.collectionView.isHidden = false
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            
            self.navigationItem.title = user.name
            self.user = user
            self.collectionView.reloadData()
        }
    }
    
    func fetchPosts() {
        var uid: String!
        if let user = self.user {
            uid = user.uid
        }else{
            uid = Auth.auth().currentUser?.uid
        }
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postID = snapshot.key
            Database.fetchPost(with: postID) { (post) in
                self.posts.append(post)
                self.posts.sort { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                }
                self.collectionView.reloadData()
            }
        }
    }
}

extension UserProfileVC: UserProfileHeaderDelegate {
    func handleFollowingTapped(for header: ProfileHeaderCell) {
        let vc = FollowVC()
        vc.viewingMode = FollowVC.ViewingMode(index: 0)
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleFollowersTapped(for header: ProfileHeaderCell) {
        let vc = FollowVC()
        vc.viewingMode = FollowVC.ViewingMode(index: 1)
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleEditProfileFollowTapped(for header: ProfileHeaderCell) {
        if header.editProfileFollowButton.titleLabel?.text?.lowercased() == "follow" {
            header.editProfileFollowButton.setTitle("Follwing", for: .normal)
            header.user?.follow()
        }else if header.editProfileFollowButton.titleLabel?.text?.lowercased() == "following"{
            header.editProfileFollowButton.setTitle("Follow", for: .normal)
            header.user?.unfollow()
        }else{
            dialogOneButton("", "not yet implement", self) { (_) in
                print("ok")
            }
        }
    }
    func handleListTapped(for header: ProfileHeaderCell) {
        dialogOneButton("", "not yet implement", self) { (_) in
            print("ok")
        }
    }
    
    func handleGridTapped(for header: ProfileHeaderCell) {
        dialogOneButton("", "not yet implement", self) { (_) in
            print("ok")
        }
    }
    
    func handleBookMarkTapped(for header: ProfileHeaderCell) {
        dialogOneButton("", "not yet implement", self) { (_) in
            print("ok")
        }
    }
    
}
