//
//  CommentsView.swift
//  Rift
//
//  Comments sheet - TikTok style
//

import SwiftUI

struct CommentsView: View {
    let videoId: String
    @StateObject private var viewModel = CommentsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var commentText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Comments list
            if viewModel.comments.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                commentsList
            }
            
            // Input
            commentInput
        }
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
        .task {
            await viewModel.loadComments(videoId: videoId)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Spacer()
            
            Text("\(viewModel.comments.count) comments")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 16)
        .overlay(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 16)
            }
        }
    }
    
    // MARK: - Comments List
    private var commentsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.comments) { comment in
                    CommentRow(comment: comment)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No comments yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Be the first to comment")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Comment Input
    private var commentInput: some View {
        HStack(spacing: 12) {
            TextField("Add comment...", text: $commentText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
                .focused($isInputFocused)
                .lineLimit(1...4)
            
            if !commentText.isEmpty {
                Button {
                    postComment()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.1, green: 0.1, blue: 0.1))
    }
    
    // MARK: - Post Comment
    private func postComment() {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            await viewModel.postComment(videoId: videoId, text: text)
            commentText = ""
            isInputFocused = false
        }
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            if let avatarUrl = comment.user?.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.user?.username ?? "unknown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                
                Text(timeAgo(from: comment.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
    }
    
    private func timeAgo(from dateString: String) -> String {
        // Simple time ago implementation
        return "Just now"
    }
}

#Preview {
    CommentsView(videoId: "test-id")
}
