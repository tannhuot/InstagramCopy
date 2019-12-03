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
