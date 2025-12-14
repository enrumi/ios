//
//  VideoOverlayView.swift
//  Rift
//
//  Overlay UI for video - right side actions + bottom info
//

import SwiftUI

struct VideoOverlayView: View {
    let video: Video
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    let onBookmark: () -> Void
    let onProfileTap: () -> Void
    
    var body: some View {
        ZStack {
            // Right side actions
            VStack {
                Spacer()
                
                rightSideActions
                    .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 12)
            
            // Bottom info
            VStack {
                Spacer()
                
                bottomInfo
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Right Side Actions
    private var rightSideActions: some View {
        VStack(spacing: 24) {
            // Profile Avatar
            Button(action: onProfileTap) {
                ZStack(alignment: .bottom) {
                    if let avatarUrl = video.user?.avatarUrl {
                        AsyncImage(url: URL(string: avatarUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
            }
            
            // Like
            ActionButton(
                icon: video.isLiked == true ? "heart.fill" : "heart",
                count: video.likeCount,
                color: video.isLiked == true ? .red : .white,
                action: onLike
            )
            
            // Comment
            ActionButton(
                icon: "bubble.right.fill",
                count: video.commentCount,
                color: .white,
                action: onComment
            )
            
            // Bookmark
            Button {
                onBookmark()
            } label: {
                VStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Text("Save")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
            }
            
            // Share
            ActionButton(
                icon: "arrowshape.turn.up.right.fill",
                count: nil,
                color: .white,
                action: onShare
            )
        }
    }
    
    // MARK: - Bottom Info
    private var bottomInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Username
            if let user = video.user {
                Text("@\(user.username)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
            
            // Caption
            if let caption = video.caption, !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let icon: String
    let count: Int?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            if let count = count {
                Text(formatCount(count))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        } else {
            return "\(count)"
        }
    }
}
