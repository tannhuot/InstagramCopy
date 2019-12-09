//
//  PostCell.swift
//  InstagramCopy
//
//  Created by Huot on 12/5/19.
//

import UIKit

class PostCell: UICollectionViewCell {
    static let reuseIndentifier = String(describing: self)
    
    var post: Post? {
        didSet{
            guard let imageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(with: imageUrl)
        }
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
