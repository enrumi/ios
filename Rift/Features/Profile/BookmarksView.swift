//
//  BookmarksView.swift
//  Rift
//
//  Saved/bookmarked videos
//

import SwiftUI

struct BookmarksView: View {
    @StateObject private var viewModel = BookmarksViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.videos.isEmpty {
                    loadingView
                } else if viewModel.videos.isEmpty {
                    emptyState
                } else {
                    videoGrid
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Bookmarks")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .task {
            await viewModel.loadBookmarks()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(.white)
            Text("Loading...")
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No bookmarks yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Save videos to watch them later")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Video Grid
    private var videoGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ],
                spacing: 2
            ) {
                ForEach(viewModel.videos) { video in
                    VideoThumbnailCell(video: video)
                }
            }
        }
    }
}

#Preview {
    BookmarksView()
}
