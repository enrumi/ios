//
//  CommentsViewModel.swift
//  Rift
//
//  Comments business logic
//

import Foundation

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Load Comments
    func loadComments(videoId: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            struct CommentsResponse: Codable {
                let comments: [Comment]
                let nextCursor: String?
                let hasMore: Bool
            }
            
            let response: CommentsResponse = try await APIService.shared.request(
                endpoint: "/videos/\(videoId)/comments",
                method: .GET,
                requiresAuth: false
            )
            
            comments = response.comments
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to load comments: \(error)")
        }
    }
    
    // MARK: - Post Comment
    func postComment(videoId: String, text: String) async {
        struct CommentRequest: Codable {
            let text: String
        }
        
        do {
            let newComment: Comment = try await APIService.shared.request(
                endpoint: "/videos/\(videoId)/comments",
                method: .POST,
                body: CommentRequest(text: text),
                requiresAuth: true
            )
            
            // Add new comment to the top
            comments.insert(newComment, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to post comment: \(error)")
        }
    }
}
