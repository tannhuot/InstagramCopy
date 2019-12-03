//
//  User.swift
//  InstagramCopy
//
//  Created by Huot on 11/27/19.
//
import Firebase

class User {
    var userName: String = ""
    var name: String = ""
    var profileImageUrl: String = ""
    var uid: String = ""
    var isFollowed = false
    
    init(uid: String, dictionary: Dictionary<String, Any>) {
        self.uid = uid
        
        if let userName = dictionary["username"] as? String {
            self.userName = userName
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return  }
        
        self.isFollowed = true
        // add followed user to current user-folling structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // add followed user to current user-folling structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid: 1])
        
//        uploadFollowNotificationToServer()
    }
    
    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.isFollowed = false
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue()
        //remove Posts here
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            }else{
                self.isFollowed = false
                completion(false)
            }
        }
    }
}
