//
//  BookmarksViewModel.swift
//  Rift
//
//  Bookmarks business logic
//

import Foundation

@MainActor
class BookmarksViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var nextCursor: String?
    private var hasMore = true
    
    // MARK: - Load Bookmarks
    func loadBookmarks() async {
        guard !isLoading && hasMore else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            struct BookmarksResponse: Codable {
                let videos: [Video]
                let nextCursor: String?
                let hasMore: Bool
            }
            
            let endpoint = nextCursor != nil 
                ? "/bookmarks?limit=20&cursor=\(nextCursor!)"
                : "/bookmarks?limit=20"
            
            let response: BookmarksResponse = try await APIService.shared.request(
                endpoint: endpoint,
                method: .GET,
                requiresAuth: true
            )
            
            videos.append(contentsOf: response.videos)
            nextCursor = response.nextCursor
            hasMore = response.hasMore
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to load bookmarks: \(error)")
        }
    }
    
    // MARK: - Toggle Bookmark
    func toggleBookmark(videoId: String) async -> Bool {
        do {
            if videos.contains(where: { $0.id == videoId }) {
                // Remove bookmark
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: "/bookmarks/\(videoId)",
                    method: .DELETE,
                    requiresAuth: true
                )
                
                videos.removeAll { $0.id == videoId }
                return false
            } else {
                // Add bookmark
                struct BookmarkRequest: Codable {
                    let videoId: String
                }
                
                let _: EmptyResponse = try await APIService.shared.request(
                    endpoint: "/bookmarks",
                    method: .POST,
                    body: BookmarkRequest(videoId: videoId),
                    requiresAuth: true
                )
                
                return true
            }
        } catch {
            print("❌ Failed to toggle bookmark: \(error)")
            return false
        }
    }
}
