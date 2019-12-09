//
//  UploadPostVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/19/19.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController {
    //MARK: - Properties
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()

    lazy var sharehButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        btn.setTitle("Share", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Test"

        setupView()
        loadImage()
        
        captionTextView.delegate = self
    }
    
    func setupView() {
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 10, paddingBottom: 0, paddingRight: 20, width: 0, height: 100)
        
        view.addSubview(sharehButton)
        sharehButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 35)
    }
    
    func loadImage() {
        guard let selectedImage = self.selectedImage else { return }
        photoImageView.image = selectedImage
    }
    
    //MARK: - Handlers
    func updateUserFeed(with postID: String) {
        // current user id
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // database valuse
        let values = [postID: 1]
        
        // update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        
        // update user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
    }
    @objc func handleSharePost() {
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currenUid = Auth.auth().currentUser?.uid
        else {
            return
        }
        
        showProgressIndicator(view: self.view, title: "Posting...")
        // image Data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else { return }

        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)

        // update storage
        let fileName = NSUUID().uuidString
        Storage.storage().reference().child("post_images").child(fileName).putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                hideProgressIndicator(view: self.view)
                print("Failed to upload...", error.localizedDescription)
            }

            // image url
            Storage.storage().reference().child("post_images").child(fileName).downloadURL(completion: { (url, error) in
                if let error = error {
                    hideProgressIndicator(view: self.view)
                    print("failed to get image url", error.localizedDescription)
                    return
                }

                if let url = url?.absoluteString {
                    // post Data
                    let values = ["caption": caption,
                                  "creationDate": creationDate,
                                  "likes": 0,
                                  "imageUrl": url,
                                  "ownerUid": currenUid] as [String: Any]

                    // post ID
                    let postID = POSTS_REF.childByAutoId()
                    postID.updateChildValues(values) { (error, ref) in
                        // update user-posts structure
                        if let postId = postID.key {
                            USER_POSTS_REF.child(currenUid).updateChildValues([postId: 1])
                            // update user feed
                            self.updateUserFeed(with: postId)
                        }
                        
                        // return to Home Feed
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
}

extension UploadPostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            sharehButton.isEnabled = false
            sharehButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        sharehButton.isEnabled = true
        sharehButton.backgroundColor = .getActiveButtonColor()
    }
}
