//
//  APIService.swift
//  Rift
//
//  High-level API service with auth and token refresh
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let networkManager = NetworkManager.shared
    private var isRefreshing = false
    private var refreshTask: Task<String, Error>?
    
    private init() {}
    
    // MARK: - Main Request with Auto Token Refresh
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        var headers: [String: String] = [:]
        
        if requiresAuth {
            guard let token = await AuthManager.shared.getAccessToken() else {
                throw NetworkError.unauthorized
            }
            headers["Authorization"] = "Bearer \(token)"
        }
        
        do {
            return try await networkManager.request(
                endpoint: endpoint,
                method: method,
                body: body,
                headers: headers
            )
        } catch NetworkError.unauthorized {
            // Try to refresh token
            guard requiresAuth else { throw NetworkError.unauthorized }
            
            let newToken = try await refreshAccessToken()
            
            // Retry with new token
            headers["Authorization"] = "Bearer \(newToken)"
            return try await networkManager.request(
                endpoint: endpoint,
                method: method,
                body: body,
                headers: headers
            )
        }
    }
    
    // MARK: - Token Refresh (Thread-Safe)
    private func refreshAccessToken() async throws -> String {
        // If already refreshing, wait for that task
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        // Create new refresh task
        let task = Task<String, Error> {
            defer { 
                refreshTask = nil
                isRefreshing = false
            }
            
            isRefreshing = true
            
            guard let refreshToken = await AuthManager.shared.getRefreshToken() else {
                await AuthManager.shared.logout()
                throw NetworkError.unauthorized
            }
            
            struct RefreshRequest: Codable {
                let refreshToken: String
            }
            
            do {
                let response: RefreshResponse = try await networkManager.request(
                    endpoint: Constants.API.Endpoints.refresh,
                    method: .POST,
                    body: RefreshRequest(refreshToken: refreshToken),
                    headers: nil
                )
                
                // Save new access token
                _ = KeychainManager.shared.save(
                    response.accessToken,
                    forKey: Constants.Keychain.accessToken
                )
                
                return response.accessToken
            } catch {
                // Refresh failed - logout user
                await AuthManager.shared.logout()
                throw NetworkError.unauthorized
            }
        }
        
        refreshTask = task
        return try await task.value
    }
    
    // MARK: - Presigned Upload URL
    func getPresignedUploadURL(filename: String, type: String, contentType: String = "video/mp4") async throws -> PresignedURLResponse {
        struct PresignRequest: Codable {
            let filename: String
            let type: String
            let contentType: String
        }
        
        return try await request(
            endpoint: Constants.API.Endpoints.presign,
            method: .POST,
            body: PresignRequest(filename: filename, type: type, contentType: contentType),
            requiresAuth: true
        )
    }
    
    // MARK: - Upload File to Presigned URL
    func uploadFile(to url: URL, data: Data, contentType: String) async throws {
        try await networkManager.uploadFile(to: url, data: data, contentType: contentType)
    }
}

// MARK: - Upload Response
struct PresignedURLResponse: Codable {
    let uploadUrl: String
    let publicUrl: String
}
