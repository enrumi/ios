//
//  SearchViewModel.swift
//  Rift
//
//  Search business logic
//

import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var users: [SearchUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Search Users
    func searchUsers(query: String) async {
        guard !query.isEmpty else {
            users = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            struct SearchResponse: Codable {
                let users: [SearchUser]
            }
            
            let response: SearchResponse = try await APIService.shared.request(
                endpoint: "/search/users?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)&limit=50",
                method: .GET,
                requiresAuth: false
            )
            
            users = response.users
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Search failed: \(error)")
        }
    }
    
    // MARK: - Clear Results
    func clearResults() {
        users = []
        errorMessage = nil
    }
}

// MARK: - Search User Model
struct SearchUser: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String?
    let avatarUrl: String?
    let bio: String?
    let isVerified: Bool?
    let stats: SearchUserStats?
}

struct SearchUserStats: Codable {
    let videosCount: Int?
    let followersCount: Int?
}
