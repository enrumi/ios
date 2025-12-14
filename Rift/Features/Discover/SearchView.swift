//
//  SearchView.swift
//  Rift
//
//  Search users and videos
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    searchBar
                    
                    // Content
                    if searchText.isEmpty {
                        emptyState
                    } else if viewModel.isLoading && viewModel.users.isEmpty {
                        loadingView
                    } else {
                        searchResults
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Search")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.system(size: 16))
                
                TextField("Search users...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { oldValue, newValue in
                        Task {
                            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
                            if searchText == newValue {
                                await viewModel.searchUsers(query: newValue)
                            }
                        }
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        viewModel.clearResults()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            
            if isSearchFocused {
                Button("Cancel") {
                    searchText = ""
                    isSearchFocused = false
                    viewModel.clearResults()
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Search for users")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Find creators and discover new content")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(.white)
                .padding(.top, 40)
            Spacer()
        }
    }
    
    // MARK: - Search Results
    private var searchResults: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.users) { user in
                    NavigationLink(destination: ProfileView(userId: user.id)) {
                        UserSearchRow(user: user)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - User Search Row
struct UserSearchRow: View {
    let user: SearchUser
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarUrl = user.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 52, height: 52)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if user.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
                
                if let displayName = user.displayName {
                    Text(displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if let stats = user.stats {
                    Text("\(stats.followersCount ?? 0) followers")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.black)
    }
}

#Preview {
    SearchView()
}
