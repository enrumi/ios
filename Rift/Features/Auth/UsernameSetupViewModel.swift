//
//  UsernameSetupViewModel.swift
//  Rift
//
//  Username setup logic with real-time availability check
//

import Foundation

@MainActor
class UsernameSetupViewModel: ObservableObject {
    @Published var isChecking = false
    @Published var isAvailable = false
    @Published var statusMessage: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var setupComplete = false
    
    private var checkTask: Task<Void, Never>?
    
    // MARK: - Check Username Availability
    func checkUsername(_ username: String) async {
        // Cancel previous check
        checkTask?.cancel()
        
        // Validate format first
        guard !username.isEmpty else {
            statusMessage = nil
            isAvailable = false
            return
        }
        
        guard username.count >= 3 else {
            statusMessage = "Too short (min 3 characters)"
            isAvailable = false
            return
        }
        
        guard username.count <= 30 else {
            statusMessage = "Too long (max 30 characters)"
            isAvailable = false
            return
        }
        
        // Check with backend
        checkTask = Task {
            isChecking = true
            
            // Debounce
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
            
            guard !Task.isCancelled else {
                isChecking = false
                return
            }
            
            do {
                struct CheckResponse: Codable {
                    let available: Bool
                    let message: String
                }
                
                let response: CheckResponse = try await APIService.shared.request(
                    endpoint: "/username/check/\(username)",
                    method: .GET,
                    requiresAuth: false
                )
                
                isAvailable = response.available
                statusMessage = response.message
                isChecking = false
            } catch {
                statusMessage = "Error checking username"
                isAvailable = false
                isChecking = false
                print("❌ Failed to check username: \(error)")
            }
        }
    }
    
    // MARK: - Setup Username
    func setupUsername(_ username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            struct SetupRequest: Codable {
                let username: String
            }
            
            struct SetupResponse: Codable {
                let user: User
                let message: String
            }
            
            let response: SetupResponse = try await APIService.shared.request(
                endpoint: "/username/setup",
                method: .POST,
                body: SetupRequest(username: username),
                requiresAuth: true
            )
            
            // Update current user in AuthManager
            AuthManager.shared.updateCurrentUser(response.user)
            
            isLoading = false
            
            // Mark as complete to trigger navigation to main app
            setupComplete = true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to setup username: \(error)")
        }
    }
}
