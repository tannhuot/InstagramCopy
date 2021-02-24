//
//  Protocols.swift
//  InstagramCopy
//
//  Created by Huot on 12/2/19.
//

protocol UserProfileHeaderDelegate {
    func handleEditProfileFollowTapped(for header: ProfileHeaderCell)
    func handleFollowingTapped(for header: ProfileHeaderCell)
    func handleFollowersTapped(for header: ProfileHeaderCell)
    func handleListTapped(for header: ProfileHeaderCell)
    func handleGridTapped(for header: ProfileHeaderCell)
    func handleBookMarkTapped(for header: ProfileHeaderCell)
}

protocol ProfileUserCellDelegate {
    func handleFollowTapped(for cell: ProfileUserCell)
}

protocol FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell)
    func handleOptionTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTab: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
    func handleMessageTapped(for cell: FeedCell)
    func handleBookMarkTapped(for cell: FeedCell)
}

protocol NotificationCellDelegate {
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
}

protocol Printable {
    var description: String {get}
}

protocol logoutDelegate {
    func didLogout()
}
