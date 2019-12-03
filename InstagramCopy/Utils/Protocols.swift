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
}

protocol ProfileUserCellDelegate {
    func handleFollowTapped(for cell: ProfileUserCell)
}
