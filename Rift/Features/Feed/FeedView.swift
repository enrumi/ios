//
//  FeedView.swift
//  Rift
//
//  Main feed screen - vertical video paging like TikTok
//

import SwiftUI
import AVKit

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var playerManager = VideoPlayerManager()
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.videos.isEmpty && viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.videos.isEmpty {
                    emptyState
                } else {
                    videoFeed(geometry: geometry)
                }
            }
        }
        .task {
            await viewModel.loadFeed()
        }
    }
    
    // MARK: - Video Feed
    private func videoFeed(geometry: GeometryProxy) -> some View {
        TabView(selection: $viewModel.currentVideoIndex) {
            ForEach(Array(viewModel.videos.enumerated()), id: \.element.id) { index, video in
                VideoFeedCell(
                    video: video,
                    playerManager: playerManager,
                    isCurrentVideo: index == viewModel.currentVideoIndex,
                    onLike: {
                        Task {
                            await viewModel.toggleLike(videoId: video.id)
                        }
                    },
                    onComment: {
                        viewModel.showCommentsForVideo = video.id
                    },
                    onShare: {
                        viewModel.showShareForVideo = video.id
                    },
                    onBookmark: {
                        Task {
                            await viewModel.toggleBookmark(videoId: video.id)
                        }
                    },
                    onProfileTap: {
                        viewModel.showProfileForUser = video.user?.id
                    }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .onChange(of: viewModel.currentVideoIndex) { oldValue, newValue in
            // Load more if needed
            viewModel.loadMoreIfNeeded(currentIndex: newValue)
        }
        .sheet(item: Binding(
            get: { viewModel.showCommentsForVideo.map { CommentSheetData(videoId: $0) } },
            set: { viewModel.showCommentsForVideo = $0?.videoId }
        )) { data in
            CommentsView(videoId: data.videoId)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.slash")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No videos yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Check back later for new content")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

// MARK: - Video Feed Cell
struct VideoFeedCell: View {
    let video: Video
    @ObservedObject var playerManager: VideoPlayerManager
    let isCurrentVideo: Bool
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    let onBookmark: () -> Void
    let onProfileTap: () -> Void
    
    @State private var showHeart = false
    
    var body: some View {
        ZStack {
            // Video Player
            if isCurrentVideo, let player = playerManager.currentPlayer {
                CustomVideoPlayerView(player: player)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // Overlay UI
            VideoOverlayView(
                video: video,
                onLike: handleLike,
                onComment: onComment,
                onShare: onShare,
                onBookmark: onBookmark,
                onProfileTap: onProfileTap
            )
            
            // Heart animation for double tap
            if showHeart {
                Image(systemName: "heart.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .scaleEffect(showHeart ? 1.3 : 0.5)
                    .opacity(showHeart ? 0 : 1)
                    .animation(.easeOut(duration: 0.6), value: showHeart)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            // Double tap to like
            handleDoubleTap()
        }
        .onTapGesture {
            // Single tap to pause/play
            playerManager.togglePlayback()
        }
        .onAppear {
            setupVideo()
        }
        .onDisappear {
            playerManager.pause()
        }
        .onChange(of: isCurrentVideo) { oldValue, newValue in
            if newValue {
                setupVideo()
            } else {
                playerManager.pause()
            }
        }
    }
    
    // MARK: - Setup Video
    private func setupVideo() {
        guard isCurrentVideo else { return }
        
        guard let url = URL(string: video.videoUrl) else {
            print("❌ Invalid video URL: \(video.videoUrl)")
            return
        }
        
        playerManager.setupPlayer(for: url)
        playerManager.play()
    }
    
    // MARK: - Handle Like
    private func handleLike() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        onLike()
    }
    
    // MARK: - Handle Double Tap
    private func handleDoubleTap() {
        // Show heart animation
        showHeart = true
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        // Like if not already liked
        if video.isLiked != true {
            onLike()
        }
        
        // Hide heart after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showHeart = false
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthManager.shared)
}
