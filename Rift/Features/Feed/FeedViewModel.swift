//
//  FeedViewModel.swift
//  Rift
//
//  Feed screen ViewModel - manages video feed
//

import Foundation
import AVFoundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentVideoIndex = 0
    @Published var showCommentsForVideo: String?
    @Published var showShareForVideo: String?
    @Published var showProfileForUser: String?
    
    private var cursor: String?
    private var hasMorePages = true
    
    // MARK: - Load Feed
    func loadFeed(refresh: Bool = false) async {
        guard !isLoading else { return }
        
        if refresh {
            cursor = nil
            hasMorePages = true
            videos = []
        }
        
        guard hasMorePages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            struct FeedResponse: Codable {
                let videos: [Video]
                let nextCursor: String?
                let hasMore: Bool
            }
            
            var endpoint = Constants.API.Endpoints.forYou + "?limit=10"
            if let cursor = cursor {
                endpoint += "&cursor=\(cursor)"
            }
            
            let response: FeedResponse = try await APIService.shared.request(
                endpoint: endpoint,
                method: .GET,
                requiresAuth: true
            )
            
            videos.append(contentsOf: response.videos)
            cursor = response.nextCursor
            hasMorePages = response.hasMore
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to load feed: \(error)")
        }
    }
    
    // MARK: - Like/Unlike
    func toggleLike(videoId: String) async {
        guard let index = videos.firstIndex(where: { $0.id == videoId }) else { return }
        
        let isLiked = videos[index].isLiked ?? false
        
        // Optimistic update
        videos[index].isLiked = !isLiked
        videos[index].likeCount += isLiked ? -1 : 1
        
        do {
            struct LikeRequest: Codable {
                let videoId: String
            }
            
            if isLiked {
                // Unlike
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: Constants.API.Endpoints.likes + "/\(videoId)",
                    method: .DELETE,
                    requiresAuth: true
                )
            } else {
                // Like
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: Constants.API.Endpoints.likes,
                    method: .POST,
                    body: LikeRequest(videoId: videoId),
                    requiresAuth: true
                )
            }
        } catch {
            // Revert on error
            videos[index].isLiked = isLiked
            videos[index].likeCount += isLiked ? 1 : -1
            print("❌ Failed to toggle like: \(error)")
        }
    }
    
    // MARK: - Toggle Bookmark
    func toggleBookmark(videoId: String) async {
        do {
            struct BookmarkRequest: Codable {
                let videoId: String
            }
            
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: "/bookmarks",
                method: .POST,
                body: BookmarkRequest(videoId: videoId),
                requiresAuth: true
            )
            
            print("✅ Bookmark added")
        } catch {
            print("❌ Failed to toggle bookmark: \(error)")
        }
    }
    
    // MARK: - Pagination
    func loadMoreIfNeeded(currentIndex: Int) {
        // Load more when reaching last 3 videos
        if currentIndex >= videos.count - 3 {
            Task {
                await loadFeed()
            }
        }
    }
}
