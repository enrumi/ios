//
//  ProfileView.swift
//  Rift
//
//  User profile - TikTok style
//

import SwiftUI

struct ProfileView: View {
    let userId: String
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    @State private var showEditProfile = false
    @State private var showBookmarks = false
    @State private var showSettings = false
    
    private var isOwnProfile: Bool {
        userId == authManager.currentUser?.id
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    profileHeader
                    
                    // Stats
                    statsSection
                    
                    // Bio
                    if let bio = viewModel.user?.bio {
                        Text(bio)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                    }
                    
                    // Action Buttons
                    actionButtons
                    
                    // Video Grid
                    videoGrid
                }
            }
        }
        .task {
            await viewModel.loadProfile(userId: userId, isOwnProfile: isOwnProfile)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(authManager)
                .onDisappear {
                    // Reload profile after editing
                    if isOwnProfile {
                        Task {
                            await viewModel.loadProfile(userId: userId, isOwnProfile: isOwnProfile)
                        }
                    }
                }
        }
        .sheet(isPresented: $showBookmarks) {
            BookmarksView()
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authManager)
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Logout button (own profile only)
            if isOwnProfile {
                HStack {
                    Spacer()
                    
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            
            // Avatar with ring
            ZStack {
                // Gradient ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.red, .pink, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 108, height: 108)
                
                // Avatar
                if let avatarUrl = viewModel.user?.avatarUrl {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.5))
                        }
                }
            }
            
            // Name and Username
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(viewModel.user?.displayName ?? viewModel.user?.username ?? "Loading")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    if viewModel.user?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
                
                if let username = viewModel.user?.username {
                    Button {
                        UIPasteboard.general.string = "@\(username)"
                        // Show copied feedback
                    } label: {
                        HStack(spacing: 6) {
                            Text("@\(username)")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.top, isOwnProfile ? 0 : 20)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(
                count: viewModel.user?.followingCount ?? 0,
                label: "Following"
            )
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 40)
            
            StatItem(
                count: viewModel.user?.followersCount ?? 0,
                label: "Followers"
            )
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 1, height: 40)
            
            StatItem(
                count: viewModel.user?.likesCount ?? 0,
                label: "Likes"
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 8) {
            if isOwnProfile {
                Button {
                    showEditProfile = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Edit profile")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8)
                }
            } else {
                Button {
                    Task {
                        await viewModel.toggleFollow()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.user?.isFollowing == true ? "checkmark" : "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text(viewModel.user?.isFollowing == true ? "Following" : "Follow")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Group {
                            if viewModel.user?.isFollowing == true {
                                Color.white.opacity(0.15)
                            } else {
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    // MARK: - Video Grid
    private var videoGrid: some View {
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

// MARK: - Stat Item
struct StatItem: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    ProfileView(userId: "test-id")
        .environmentObject(AuthManager.shared)
}
