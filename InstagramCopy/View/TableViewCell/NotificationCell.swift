//
//  NotificationCell.swift
//  InstagramCopy
//
//  Created by Huot on 30/12/20.
//

import UIKit

class NotificationCell: UITableViewCell {
    static let reuseIdentifire = String(describing: NotificationCell.self)
    
    //MARK: - Property
    var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        didSet {
            guard let profileImageUrl = notification?.user.profileImageUrl
            else { return }
            
            profileImageView.loadImage(with: profileImageUrl)
            
            configureNotificationLabel()
            
            configureNotificationType()
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageUrl)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "profile_selected")
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(named: "profile_selected")
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFill
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(postTap)
        
        return iv
    }()
    
    let notificationLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 2
        return lb
    }()
    
    lazy var followButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("loading", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.getActiveButtonColor
        btn.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Handlers
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    func configureNotificationLabel() {
        guard let notificationMessage = self.notification?.notificationType.description,
              let username = self.notification?.user.userName
        else { return }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: getTimeStamp(from: notification?.creationDate ?? Date(), to: Date()) ?? "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        notificationLabel.attributedText = attributedText
    }
    
    func configureNotificationType() {
        guard let notification = self.notification,
              let user = self.notification?.user
        else { return }
                
        if notification.notificationType != .Follow {
            // notification is comment/like
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 40, height: 40)
            postImageView.layer.cornerRadius = 5
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }else{
            // notification is follow
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.layer.cornerRadius = 3
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            user.checkIfUserIsFollowed { [self] (isFollowed) in
                followButton.configure(didFollow: isFollowed)
            }
        }
        
        addSubview(notificationLabel)
        notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: notification.notificationType == .Follow ? followButton.leftAnchor:postImageView.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        // profile img view
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
