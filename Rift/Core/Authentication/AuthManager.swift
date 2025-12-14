//
//  AuthManager.swift
//  Rift
//
//  Authentication state management
//

import Foundation
import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let keychain = KeychainManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        checkAuthState()
    }
    
    // MARK: - Check Auth State
    func checkAuthState() {
        if let accessToken = keychain.retrieve(forKey: Constants.Keychain.accessToken),
           !accessToken.isEmpty {
            isAuthenticated = true
            // Load current user
            Task {
                await loadCurrentUser()
            }
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    // MARK: - Register
    func register(username: String, email: String, password: String, displayName: String?) async throws {
        let request = RegisterRequest(
            username: username,
            email: email,
            password: password,
            displayName: displayName
        )
        
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: Constants.API.Endpoints.register,
            method: .POST,
            body: request,
            requiresAuth: false
        )
        
        saveTokens(response)
        isAuthenticated = true
        currentUser = response.user
    }
    
    // MARK: - Login
    func login(username: String, password: String) async throws {
        let request = LoginRequest(username: username, password: password)
        
        let response: AuthResponse = try await APIService.shared.request(
            endpoint: Constants.API.Endpoints.login,
            method: .POST,
            body: request,
            requiresAuth: false
        )
        
        saveTokens(response)
        isAuthenticated = true
        currentUser = response.user
    }
    
    // MARK: - Logout
    func logout() async {
        // Call backend logout endpoint
        do {
            let _: EmptyResponse = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.logout,
                method: .POST,
                requiresAuth: true
            )
        } catch {
            print("Logout API call failed: \(error)")
        }
        
        // Clear local state
        keychain.clearAll()
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Load Current User
    private func loadCurrentUser() async {
        do {
            let user: User = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.me,
                method: .GET,
                requiresAuth: true
            )
            currentUser = user
        } catch {
            print("Failed to load current user: \(error)")
            // If user load fails, logout
            await logout()
        }
    }
    
    // MARK: - Save Tokens
    private func saveTokens(_ response: AuthResponse) {
        _ = keychain.save(response.accessToken, forKey: Constants.Keychain.accessToken)
        _ = keychain.save(response.refreshToken, forKey: Constants.Keychain.refreshToken)
        _ = keychain.save(response.user.id, forKey: Constants.Keychain.userId)
    }
    
    // MARK: - Get Access Token
    func getAccessToken() -> String? {
        return keychain.retrieve(forKey: Constants.Keychain.accessToken)
    }
    
    // MARK: - Get Refresh Token
    func getRefreshToken() -> String? {
        return keychain.retrieve(forKey: Constants.Keychain.refreshToken)
    }
    
    // MARK: - Update Current User
    func updateCurrentUser(_ user: User) {
        currentUser = user
    }
}
