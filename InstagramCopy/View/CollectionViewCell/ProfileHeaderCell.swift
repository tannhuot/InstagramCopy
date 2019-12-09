//
//  ProfileHeaderCell.swift
//  InstagramCopy
//
//  Created by Huot on 11/20/19.
//

import UIKit
import Firebase

class ProfileHeaderCell: UICollectionViewCell {
    //MARK: - Properties
    var delegage: UserProfileHeaderDelegate?
    var user: User? {
        didSet{
            configureEditFollowButton()
            setUserStats(for: user)
            nameLabel.text = user?.name
            guard let profileImageUrl = user?.profileImageUrl else { return }
            profileImageView.loadImage(with: profileImageUrl)
        }
    }
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "profile_selected")
        iv.backgroundColor = .lightGray
        return iv
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Your name here"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    let postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let attributedText = NSMutableAttributedString(string: "999\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "Posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        return label
    }()
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    let editProfileFollowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.5
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    lazy var gridButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(handleGridButton), for: .touchUpInside)
        return btn
    }()
    lazy var listButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(handleListButton), for: .touchUpInside)
        return btn
    }()
    lazy var bookmarkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        btn.tintColor = UIColor(white: 0, alpha: 0.2)
        btn.addTarget(self, action: #selector(handleBookMarkButton), for: .touchUpInside)
        return btn
    }()
    //MARK: - Handlers
    @objc func handleFollowingTapped() {
        delegage?.handleFollowingTapped(for: self)
    }
    @objc func handleFollowersTapped() {
        delegage?.handleFollowersTapped(for: self)
    }
    @objc func handleEditProfileFollowButton() {
        delegage?.handleEditProfileFollowTapped(for: self)
    }
    @objc func handleListButton() {
        delegage?.handleListTapped(for: self)
    }
    @objc func handleGridButton() {
        delegage?.handleGridTapped(for: self)
    }
    @objc func handleBookMarkButton() {
        delegage?.handleBookMarkTapped(for: self)
    }
    func setUserStats(for user: User?) {
        guard let uid = user?.uid else { return }
        
        var numberOfFollowers = 0
        var numberOfFollowing = 0
        // get number of follower
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                numberOfFollowers = snapshot.count
            }else{
                numberOfFollowers = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followersLabel.attributedText = attributedText
        }
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, Any> {
                numberOfFollowing = snapshot.count
            }else{
                numberOfFollowing = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "Following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            self.followingLabel.attributedText = attributedText
        }
    }
    func configureEditFollowButton() {
        guard
            let currentUid = Auth.auth().currentUser?.uid,
            let user = self.user
        else { return }
        
        if currentUid == user.uid {
            // configure as Edit Profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        }else{
            // configure as Follow button
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = .getActiveButtonColor()
            
            user.checkIfUserIsFollowed { (followed) in
                if followed{
                    self.editProfileFollowButton.setTitle("Following", for: .normal)
                }else{
                    self.editProfileFollowButton.setTitle("Follow", for: .normal)
                }
            }
        }
    }
    func configureUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 15, width: 0, height: 0)
        
    }
    func configureBottomToolBar() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 15, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 40
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        configureUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 35)
        editProfileFollowButton.addTarget(self, action: #selector(handleEditProfileFollowButton), for: .touchUpInside)
        
        configureBottomToolBar()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
