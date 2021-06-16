//
//  Extensions.swift
//  InstagramCopy
//
//  Created by Huot on 11/4/19.
//

import UIKit
import Firebase

//MARK: - UIView
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
extension Database {
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchPost(with postID: String, completion: @escaping(Post) -> ()) {
        POSTS_REF.child(postID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else { return }
            guard let ownerID = dictionary["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerID) { (user) in
                let post = Post(postID: postID,user: user, dictionary: dictionary)
                completion(post)
            }
        }
    }
}

extension UIButton {
    func configure(didFollow: Bool) {
        if didFollow {
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
        }else{
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }
    }
}

extension String {
    func timeAgoSinceDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            var formattedString = self.replacingOccurrences(of: "Z", with: "")
            if let lowerBound = formattedString.range(of: ".")?.lowerBound {
                formattedString = "\(formattedString[..<lowerBound])"
            }
            
            guard let date = dateFormatter.date(from: formattedString) else {
                return self
            }
            
            let fromDate =  date
            
            let toDate = Date()
            
            // Month
            if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
                dateFormatter.dateFormat = "dd MMM yyyy"
                
                return dateFormatter.string(from: fromDate)
            }
            
            // Day
            if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
                
                return interval == 1 ? "\(interval)" + " " + "Day ago" : "\(interval)" + " " + "Days ago"
            }
            
            // Hours
            if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
                
                return interval == 1 ? "\(interval)" + " " + "Hour ago" : "\(interval)" + " " + "Hours ago"
            }
            
            // Minute
            if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
                
                return interval == 1 ? "\(interval)" + " " + "Minute ago" : "\(interval)" + " " + "Minutes ago"
            }
            
            return "A moment ago"
        }
}
