//
//  EditProfileViewModel.swift
//  Rift
//
//  Edit profile business logic
//

import Foundation

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var uploadedAvatarUrl: String?
    
    // MARK: - Upload Avatar
    func uploadAvatar(imageData: Data) async -> Bool {
        do {
            // 1. Get presigned URL for image
            let presignedResponse: PresignedURLResponse = try await APIService.shared.getPresignedUploadURL(
                filename: "avatar_\(UUID().uuidString).jpg",
                type: "image",
                contentType: "image/jpeg"
            )
            
            // 2. Upload image to presigned URL
            guard let uploadURL = URL(string: presignedResponse.uploadUrl) else {
                throw NSError(domain: "Invalid upload URL", code: -1)
            }
            
            try await APIService.shared.uploadFile(
                to: uploadURL,
                data: imageData,
                contentType: "image/jpeg"
            )
            
            // 3. Save the public URL
            uploadedAvatarUrl = presignedResponse.publicUrl
            return true
        } catch {
            errorMessage = "Failed to upload avatar: \(error.localizedDescription)"
            print("❌ Failed to upload avatar: \(error)")
            return false
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(displayName: String?, bio: String?, avatarUrl: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            struct UpdateProfileRequest: Codable {
                let displayName: String?
                let bio: String?
                let avatarUrl: String?
            }
            
            let request = UpdateProfileRequest(
                displayName: displayName,
                bio: bio,
                avatarUrl: avatarUrl ?? uploadedAvatarUrl
            )
            
            let updatedUser: User = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.me,
                method: .PATCH,
                body: request,
                requiresAuth: true
            )
            
            // Update auth manager
            AuthManager.shared.updateCurrentUser(updatedUser)
            
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to update profile: \(error)")
            return false
        }
    }
}
