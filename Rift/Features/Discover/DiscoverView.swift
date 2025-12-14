//
//  DiscoverView.swift
//  Rift
//
//  Search and discover - TikTok style
//

import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Trending
                        if !viewModel.trendingHashtags.isEmpty {
                            trendingSection
                        }
                        
                        // Search Results or Grid
                        if searchText.isEmpty {
                            discoverGrid
                        } else {
                            searchResults
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadDiscover()
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("Search", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Trending Section
    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trending")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.trendingHashtags, id: \.self) { hashtag in
                        HashtagChip(hashtag: hashtag)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Discover Grid
    private var discoverGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2),
                GridItem(.flexible(), spacing: 2)
            ],
            spacing: 2
        ) {
            ForEach(viewModel.discoverVideos) { video in
                VideoThumbnailCell(video: video)
            }
        }
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        VStack(spacing: 16) {
            if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                Text("No results found")
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 40)
            } else {
                ForEach(viewModel.searchResults) { video in
                    VideoSearchRow(video: video)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Hashtag Chip
struct HashtagChip: View {
    let hashtag: String
    
    var body: some View {
        Text("#\(hashtag)")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
    }
}

// MARK: - Video Thumbnail Cell
struct VideoThumbnailCell: View {
    let video: Video
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Thumbnail
            if let thumbnailUrl = video.thumbnailUrl {
                AsyncImage(url: URL(string: thumbnailUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(9/16, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(9/16, contentMode: .fill)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(9/16, contentMode: .fill)
            }
            
            // View count overlay
            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.system(size: 10))
                Text("\(formatCount(video.viewCount))")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.5))
            .cornerRadius(4)
            .padding(6)
        }
        .clipped()
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

// MARK: - Video Search Row
struct VideoSearchRow: View {
    let video: Video
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnailUrl = video.thumbnailUrl {
                AsyncImage(url: URL(string: thumbnailUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 100, height: 140)
                .clipped()
                .cornerRadius(8)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                if let user = video.user {
                    Text("@\(user.username)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                if let caption = video.caption {
                    Text(caption)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label("\(formatCount(video.likeCount))", systemImage: "heart")
                    Label("\(formatCount(video.viewCount))", systemImage: "play")
                }
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

#Preview {
    DiscoverView()
}
