//
//  Notification.swift
//  InstagramCopy
//
//  Created by dev229 on 23/2/21.
//

import Foundation

class Notification {
    
    enum NotificationType: Int, Printable {
        
        case Like
        case Comment
        case Follow
        
        var description: String {
            switch self {
            case .Like: return " like your post "
            case .Comment: return " commented on your post "
            case .Follow: return " started following your "
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            default: self = .Like
            }
        }
    }
    
    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var notificationType: NotificationType!
    var didCheck = false
    
    init(user: User, post: Post? = nil, dictionary: Dictionary<String, Any>) {
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let type = dictionary["type"] as? Int {
            self.notificationType = NotificationType(index: type)
        }
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }
        
        if let checked = dictionary["checked"] as? Int {
            if checked == 0 {
                self.didCheck = false
            }else{
                self.didCheck = true
            }
        }
    }
}
