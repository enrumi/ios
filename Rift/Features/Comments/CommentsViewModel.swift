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
            }
            
            let response: CommentsResponse = try await APIService.shared.request(
                endpoint: "\(Constants.API.Endpoints.videos)/\(videoId)/comments",
                method: .GET,
                requiresAuth: true
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
            let videoId: String
            let text: String
            
            enum CodingKeys: String, CodingKey {
                case videoId = "video_id"
                case text
            }
        }
        
        do {
            struct CommentResponse: Codable {
                let comment: Comment
            }
            
            let response: CommentResponse = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.comments,
                method: .POST,
                body: CommentRequest(videoId: videoId, text: text),
                requiresAuth: true
            )
            
            // Add new comment to the top
            comments.insert(response.comment, at: 0)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to post comment: \(error)")
        }
    }
}
