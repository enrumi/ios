//
//  DiscoverViewModel.swift
//  Rift
//
//  Discover/Search business logic
//

import Foundation

@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var discoverVideos: [Video] = []
    @Published var searchResults: [Video] = []
    @Published var trendingHashtags: [String] = []
    @Published var isLoading = false
    
    // MARK: - Load Discover
    func loadDiscover() async {
        isLoading = true
        
        do {
            // Load trending videos for grid
            struct FeedResponse: Codable {
                let videos: [Video]
            }
            
            let response: FeedResponse = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.forYou + "?limit=30",
                method: .GET,
                requiresAuth: true
            )
            
            discoverVideos = response.videos
            
            // Mock trending hashtags (можно сделать отдельный endpoint)
            trendingHashtags = ["rift", "fyp", "trending", "viral", "creative"]
            
            isLoading = false
        } catch {
            isLoading = false
            print("❌ Failed to load discover: \(error)")
        }
    }
    
    // MARK: - Search
    func search(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        do {
            struct SearchResponse: Codable {
                let videos: [Video]
            }
            
            let response: SearchResponse = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.search + "?q=\(query)&type=videos",
                method: .GET,
                requiresAuth: true
            )
            
            searchResults = response.videos
            isLoading = false
        } catch {
            isLoading = false
            print("❌ Search failed: \(error)")
        }
    }
}
