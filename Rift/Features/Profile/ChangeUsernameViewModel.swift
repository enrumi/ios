//
//  ChangeUsernameViewModel.swift
//  Rift
//
//  Change username logic
//

import Foundation

@MainActor
class ChangeUsernameViewModel: ObservableObject {
    @Published var isChecking = false
    @Published var isAvailable = false
    @Published var statusMessage: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var updatedUser: User?
    
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
    
    // MARK: - Change Username
    func changeUsername(_ username: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            struct ChangeRequest: Codable {
                let username: String
            }
            
            struct ChangeResponse: Codable {
                let user: User
                let message: String
            }
            
            let response: ChangeResponse = try await APIService.shared.request(
                endpoint: "/username/change",
                method: .PATCH,
                body: ChangeRequest(username: username),
                requiresAuth: true
            )
            
            // Store updated user
            updatedUser = response.user
            
            isLoading = false
            return true
        } catch {
            isLoading = false
            
            // Parse error message
            if let errorData = (error as NSError).userInfo["data"] as? Data,
               let errorJson = try? JSONSerialization.jsonObject(with: errorData) as? [String: Any],
               let errorMsg = errorJson["error"] as? String {
                errorMessage = errorMsg
            } else {
                errorMessage = error.localizedDescription
            }
            
            print("❌ Failed to change username: \(error)")
            return false
        }
    }
}
