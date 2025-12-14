//
//  Models.swift
//  Rift
//
//  Data models matching backend API
//

import Foundation

// MARK: - User
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let email: String?  // Optional - not always returned by API
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let isVerified: Bool?
    var followersCount: Int?
    let followingCount: Int?
    let likesCount: Int?
    var isFollowing: Bool?
    let createdAt: String?  // Optional - not always returned by API
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, bio, displayName, avatarUrl, isVerified, createdAt
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case likesCount = "likes_count"
        case isFollowing = "is_following"
    }
}

// MARK: - Video
struct Video: Codable, Identifiable {
    let id: String
    let userId: String
    let videoUrl: String
    let thumbnailUrl: String?
    let caption: String?
    let duration: Int?
    let isPublic: Bool?
    var likeCount: Int
    let commentCount: Int
    let viewCount: Int
    let shareCount: Int?
    var isLiked: Bool?
    let createdAt: String
    let updatedAt: String?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, videoUrl, thumbnailUrl, caption, duration, isPublic
        case likeCount, commentCount, viewCount, shareCount, createdAt, updatedAt, user
        case isLiked = "is_liked"
    }
}

// Comment model moved to Comment.swift to avoid duplication

// MARK: - Auth Responses
struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let displayName: String?
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct RefreshResponse: Codable {
    let accessToken: String
}

// MARK: - Generic API Response
struct APIResponse<T: Codable>: Codable {
    let data: T
}

struct ErrorResponse: Codable {
    let error: String
    let message: String?
}

// MARK: - Empty Response
struct EmptyResponse: Codable {
    // Used for API endpoints that return no data (e.g., DELETE, some POST)
}
