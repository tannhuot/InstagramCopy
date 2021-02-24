//
//  CommentCell.swift
//  InstagramCopy
//
//  Created by Huot on 6/5/20.
//

import UIKit

class CommentCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: self)
    // MARK: Properties
    var comment: Comment? {
        didSet {
            guard let user = comment?.user else { return }
            profileImageView.loadImage(with: user.profileImageUrl)
            let attributedText = NSMutableAttributedString(string: user.userName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
            attributedText.append(NSAttributedString(string: " " + (comment?.commentText ?? ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
            attributedText.append(NSAttributedString(string: " " + (getTimeStamp(from: comment?.creationgDate ?? Date(), to: Date()) ?? ""), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            commentTextView.attributedText = attributedText
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
    let commentTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 12)
        tv.isScrollEnabled = false
        tv.isUserInteractionEnabled = false
        return tv
    }()
    let separatorView: UIView = {
       let view = UIView()
        view.backgroundColor = .separatorColor
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 24
        
        addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 20, width: 0, height: 0)
        addSubview(separatorView)
        separatorView.anchor(top: nil, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
