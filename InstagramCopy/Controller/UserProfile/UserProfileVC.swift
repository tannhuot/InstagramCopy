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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white

        // Register cell classes
//        self.collectionView!.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderReuseIdentifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if user == nil {
            fetchCurrentUserData()
        }else{
            navigationItem.title = user?.name
        }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
    
        return cell
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
}

extension UserProfileVC: UserProfileHeaderDelegate {
    func handleFollowingTapped(for header: ProfileHeaderCell) {
        let vc = FollowVC()
        vc.isFromFollowing = true
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
        print("followings")
    }
    
    func handleFollowersTapped(for header: ProfileHeaderCell) {
        let vc = FollowVC()
        vc.isFromFollowing = false
        vc.uid = user?.uid
        navigationController?.pushViewController(vc, animated: true)
        print("followers")
    }
    
    func handleEditProfileFollowTapped(for header: ProfileHeaderCell) {
        if header.editProfileFollowButton.titleLabel?.text?.lowercased() == "follow" {
            header.editProfileFollowButton.setTitle("Follwing", for: .normal)
            header.user?.follow()
        }else if header.editProfileFollowButton.titleLabel?.text?.lowercased() == "following"{
            header.editProfileFollowButton.setTitle("Follow", for: .normal)
            header.user?.unfollow()
        }else{
            print("Edit Profile")
        }
    }
}
