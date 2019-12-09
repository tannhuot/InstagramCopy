//
//  FeedCell.swift
//  InstagramCopy
//
//  Created by Huot on 12/5/19.
//

import UIKit
import Firebase

class FeedCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: self)
    
    var delegate: FeedCellDelegate?
    var post: Post? {
        didSet{
            guard
                let ownerID = post?.ownerUid,
                let imageUrl = post?.imageUrl,
                let likes = post?.likes
            else { return }
            Database.fetchUser(with: ownerID) { (user) in
                self.profileImageView.loadImage(with: user.profileImageUrl)
                self.userNameButton.setTitle(user.userName, for: .normal)
                self.setupPostCaption(user: user)
            }
            
            postImageView.loadImage(with: imageUrl)
            likeLabel.text = "\(likes) like"
            configureLikeButton()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var userNameButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("User Name", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn.addTarget(self, action: #selector(handleUserNameTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var optionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("•••", for: .normal) // hold "option + 8" to get •
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleOptionTapped), for: .touchUpInside)
        return btn
    }()
    
    let postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var likeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "like_unselected"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var commentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "comment"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var messageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "send2"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleMessageTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var bookMarkPostButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "ribbon"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(handleBookMarkTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var likeLabel: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.boldSystemFont(ofSize: 12)
        lb.text = "999 likes"
        let likeTap  = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired = 1
        lb.isUserInteractionEnabled = true
        lb.addGestureRecognizer(likeTap)
        return lb
    }()
    
    let captionLabel: UILabel = {
        let lb = UILabel()
        let attributedText = NSMutableAttributedString(string: "User Name: ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: "some test caption", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        lb.attributedText = attributedText
        return lb
    }()
    
    let postTimeLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lightGray
        lb.font = UIFont.boldSystemFont(ofSize: 10)
        lb.text = "999 DAYS AGO"
        return lb
    }()
    
    //MARK: - Handlers
    @objc func handleShowLikes() {
        delegate?.handleShowLikes(for: self)
    }
    @objc func handleUserNameTapped() {
        delegate?.handleUserNameTapped(for: self)
    }
    @objc func handleOptionTapped() {
        delegate?.handleOptionTapped(for: self)
    }
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(for: self)
    }
    @objc func handleCommentTapped() {
        delegate?.handleCommentTapped(for: self)
    }
    @objc func handleMessageTapped() {
        delegate?.handleMessageTapped(for: self)
    }
    @objc func handleBookMarkTapped() {
        delegate?.handleBookMarkTapped(for: self)
    }
    
    func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        // profile image view
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20
        // userName button
        addSubview(userNameButton)
        userNameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        userNameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        // option button
        addSubview(optionButton)
        optionButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        // post Image View
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureActionButton()
        
        // save post button
        addSubview(bookMarkPostButton)
        bookMarkPostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 10, width: 20, height: 25)
        // like Label
        addSubview(likeLabel)
        likeLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        // caption Label
        addSubview(captionLabel)
        captionLabel.anchor(top: likeLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: 0, height: 0)
        // post time label
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    func configureActionButton() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
    }
    
    func setupPostCaption(user: User) {
        guard let caption = self.post?.caption else { return }
        let attributedText = NSMutableAttributedString(string: user.userName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)])
        attributedText.append(NSAttributedString(string: ": \(caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        captionLabel.attributedText = attributedText
    }
}
