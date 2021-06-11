//
//  Post.swift
//  InstagramCopy
//
//  Created by Huot on 12/4/19.
//
import Foundation
import Firebase

class Post {
    var caption: String = ""
    var likes: Int = 0
    var imageUrl: String = ""
    var ownerUid: String = ""
    var creationDate: Date!
    var postID: String = ""
    var user: User?
    var didLike = false
    
    init(postID: String!,user: User, dictionary: Dictionary<String, Any>) {
        self.postID = postID
        self.user = user
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        if addLike {
            
            // update user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postID: 1]) { (error, ref) in
                
                //  send like notification to server
                self.sendLikeNotificationToSever()
                
                // update post-likes struture
                POST_LIKES_REF.child(self.postID).updateChildValues([currentUid: 1], withCompletionBlock: { (error, ref) in
                    self.likes += 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postID).child("likes").setValue(self.likes)
                })
            }
        }else{
            
            // observe database for notifcation id to remove
            USER_LIKES_REF.child(currentUid).child(postID).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let notificationID = snapshot.value as? String else { return }
                NOTIFICATION_REF.child(self.ownerUid).child(notificationID).removeValue { (err, ref) in
                    // remove user-likes structure
                    USER_LIKES_REF.child(currentUid).child(self.postID).removeValue { (error, ref) in
                        // remove post-likes struture
                        POST_LIKES_REF.child(self.postID).child(currentUid).removeValue { (error, ref) in
                            guard self.likes > 0 else { return }
                            self.likes -= 1
                            self.didLike = false
                            completion(self.likes)
                            POSTS_REF.child(self.postID).child("likes").setValue(self.likes)
                        }
                    }
                }
            }
        }
    }
    
    private func sendLikeNotificationToSever() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        if currentUid != self.ownerUid{
            // notification value
            let values: [String : Any] = ["checked": 0,
                                         "creationDate": creationDate,
                                         "uid": currentUid,
                                         "type": LIKE_INT_VALUE,
                                         "postId": postID
                                        ]
            
            // notification database reference
            let notificationRef = NOTIFICATION_REF.child(self.ownerUid).childByAutoId()
            
            // upload notification value to database
            notificationRef.updateChildValues(values) { (err, ref) in
                USER_LIKES_REF.child(currentUid).child(self.postID).setValue(notificationRef.key)
            }
        }
    }
    
    func deletePost() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Storage.storage().reference(forURL: imageUrl).delete(completion: nil)
        
        // Delete from follower feed
        USER_FOLLOWER_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let followers = snapshot.children.allObjects as? [DataSnapshot] else { return }

            followers.forEach { (follower) in
                USER_POSTS_REF.child(follower.key).child(self.postID).removeValue()
            }
        }
        
        // Delete from newfeed
        USER_FEED_REF.child(currentUid).child(postID).removeValue()
        
        // Delete from user post
        USER_POSTS_REF.child(currentUid).child(postID).removeValue()
        
        // Delete from post-like, user-like, and notification
        POST_LIKES_REF.child(postID).observeSingleEvent(of: .value) { [self](snapshot) in
            guard let postLikes = snapshot.children.allObjects as? [DataSnapshot] else { return }

            postLikes.forEach { (postLike) in
                USER_LIKES_REF.child(postLike.key).child(self.postID).observeSingleEvent(of: .value) { (snapshot) in
                    guard let notificationId = snapshot.value as? String else { return }
                    
                    NOTIFICATION_REF.child(ownerUid).child(notificationId).removeValue { (_, _) in
                        POST_LIKES_REF.child(postID).removeValue()
                        
                        USER_LIKES_REF.child(postLike.key).child(postID).removeValue()
                    }
                }
            }
        }
        
        // Delete Comment
        COMMENT_REF.child(postID).removeValue()
        
        //
        POSTS_REF.child(postID).removeValue()
    }
}
