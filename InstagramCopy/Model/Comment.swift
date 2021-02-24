//
//  Comment.swift
//  InstagramCopy
//
//  Created by Huot on 6/5/20.
//

import Foundation
import Firebase

class Comment {
    var uid: String!
    var commentText: String!
    var creationgDate: Date!
    var user: User?
    init(user: User, dictionary: Dictionary<String, AnyObject>) {
        self.user = user
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationgDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
