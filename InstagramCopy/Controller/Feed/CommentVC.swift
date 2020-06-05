//
//  CommentVC.swift
//  InstagramCopy
//
//  Created by Huot on 6/5/20.
//

import Foundation
import Firebase
import UIKit

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // MARK: Properties
    var postId = ""
    var comments = [Comment]()
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        view.addSubview(postButton)
        postButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        postButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.addSubview(commentTextField)
        commentTextField.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        let separatorView = UIView()
        view.addSubview(separatorView)
        separatorView.backgroundColor = .separatorColor
        separatorView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        return view
    }()
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment..."
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    lazy var postButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return btn
    }()
    // MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        navigationItem.title = "Comments"
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.reuseIdentifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        fetchComments()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        tabBarController?.tabBar.isHidden = true
        scrollToLastComment()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    // MARK: Handler
    @objc func keyboardWillShow() {
        scrollToLastComment()
    }
    @objc func handleUploadComment() {
        guard let commentText = commentTextField.text, commentText != "" else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = ["commentText": commentText,
                      "creationDate": creationDate,
                      "uid":uid] as [String : Any]
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            self.commentTextField.text = ""
        }
    }
    private func fetchComments() {
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            guard let dic = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dic["uid"] as? String else { return }
            Database.fetchUser(with: uid) { (user) in
                let comment = Comment(user: user, dictionary: dic)
                self.comments.append(comment)
                self.collectionView.reloadData()
                self.scrollToLastComment()
            }
        }
    }
    private func scrollToLastComment() {
        if comments.count > 0 {
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
}
