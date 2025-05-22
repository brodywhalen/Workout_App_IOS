//
//  User.swift
//  Workout_App_IOS
//
//  Created by Brody Whalen on 5/12/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    var email: String
    var username: String
    var displayName: String
    var profileImageURL: URL?
    var bio: String?
    var followersCount: Int
    var followingCount: Int
    // options
}

struct Friendship: Identifiable, Codable {
    let id: String               // UUID or composite of user IDs
    let userId: String           // The user who initiated
    let friendId: String         // The user who is being friended
    let status: FriendshipStatus
    let createdAt: Date
}

enum FriendshipStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case blocked
}

// Add Sessions
//


