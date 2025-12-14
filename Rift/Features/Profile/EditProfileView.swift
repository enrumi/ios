//
//  EditProfileView.swift
//  Rift
//
//  Edit profile screen - TikTok style
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditProfileViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Photo
                        profilePhotoSection
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Display Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                TextField("Display name", text: $displayName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Bio
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                    .lineLimit(3...6)
                                
                                Text("\(bio.count)/150")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Error Message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Edit Profile")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveProfile()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.red)
                        } else {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.red)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onAppear {
            loadCurrentUserData()
        }
        .onChange(of: selectedPhotoItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    
                    // Compress and upload image
                    if let jpegData = uiImage.jpegData(compressionQuality: 0.7) {
                        await viewModel.uploadAvatar(imageData: jpegData)
                    }
                }
            }
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else if let avatarUrl = authManager.currentUser?.avatarUrl,
                          let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { image in
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
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
                
                // Camera Icon Overlay
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
            }
            .overlay {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Color.clear
                }
            }
            
            Text("Change Photo")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
        }
    }
    
    // MARK: - Load Current User Data
    private func loadCurrentUserData() {
        if let user = authManager.currentUser {
            displayName = user.displayName ?? user.username
            bio = user.bio ?? ""
        }
    }
    
    // MARK: - Save Profile
    private func saveProfile() {
        Task {
            let success = await viewModel.updateProfile(
                displayName: displayName.isEmpty ? nil : displayName,
                bio: bio.isEmpty ? nil : bio
            )
            
            if success {
                // Reload current user data from server
                do {
                    let updatedUser: User = try await APIService.shared.request(
                        endpoint: Constants.API.Endpoints.me,
                        method: .GET,
                        requiresAuth: true
                    )
                    authManager.updateCurrentUser(updatedUser)
                } catch {
                    print("❌ Failed to reload user data: \(error)")
                }
                
                dismiss()
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthManager.shared)
}
