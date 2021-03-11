//
//  Constants.swift
//  InstagramCopy
//
//  Created by Huot on 12/2/19.
//

import Firebase

let DB_REF = Database.database().reference()

let USER_REF = DB_REF.child("users")

let USER_FOLLOWER_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

let USER_FEED_REF = DB_REF.child("user-feed")

let USER_LIKES_REF = DB_REF.child("user-likes")
let POST_LIKES_REF = DB_REF.child("post-likes")

let COMMENT_REF = DB_REF.child("comments")

let NOTIFICATION_REF = DB_REF.child("notifications")

let MESSAGE_REF = DB_REF.child("messages")
let USER_MESSAGE_REF = DB_REF.child("user-messages")

let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
