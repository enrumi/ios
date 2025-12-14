//
//  ProfileViewModel.swift
//  Rift
//
//  Profile business logic
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var videos: [Video] = []
    @Published var isLoading = false
    
    // MARK: - Load Profile
    func loadProfile(userId: String, isOwnProfile: Bool = false) async {
        isLoading = true
        
        do {
            // Load user - use /users/me for own profile
            let userEndpoint = isOwnProfile 
                ? Constants.API.Endpoints.me
                : "\(Constants.API.Endpoints.users)/\(userId)"
            
            let loadedUser: User = try await APIService.shared.request(
                endpoint: userEndpoint,
                method: .GET,
                requiresAuth: true
            )
            user = loadedUser
            
            // Use username for videos endpoint (backend expects username, not ID)
            let username = loadedUser.username
            
            // Load user's videos
            struct VideosResponse: Codable {
                let videos: [Video]
                let nextCursor: String?
                let hasMore: Bool
            }
            
            let videosResponse: VideosResponse = try await APIService.shared.request(
                endpoint: "\(Constants.API.Endpoints.users)/\(username)/videos",
                method: .GET,
                requiresAuth: true
            )
            videos = videosResponse.videos
            
            isLoading = false
        } catch {
            isLoading = false
            print("❌ Failed to load profile: \(error)")
        }
    }
    
    // MARK: - Toggle Follow
    func toggleFollow() async {
        guard let user = user else { return }
        let isFollowing = user.isFollowing ?? false
        
        // Optimistic update
        self.user?.isFollowing = !isFollowing
        if let count = self.user?.followersCount {
            self.user?.followersCount = count + (isFollowing ? -1 : 1)
        }
        
        do {
            struct FollowRequest: Codable {
                let followingId: String
            }
            
            if isFollowing {
                // Unfollow
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: "\(Constants.API.Endpoints.follows)/\(user.id)",
                    method: .DELETE,
                    requiresAuth: true
                )
            } else {
                // Follow
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: Constants.API.Endpoints.follows,
                    method: .POST,
                    body: FollowRequest(followingId: user.id),
                    requiresAuth: true
                )
            }
        } catch {
            // Revert on error
            self.user?.isFollowing = isFollowing
            if let count = self.user?.followersCount {
                self.user?.followersCount = count + (isFollowing ? 1 : -1)
            }
            print("❌ Failed to toggle follow: \(error)")
        }
    }
}
