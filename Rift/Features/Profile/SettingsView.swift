//
//  SettingsView.swift
//  Rift
//
//  Settings menu - Minimal 2025 style
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var showChangeUsername = false
    @State private var showBookmarks = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile header
                        profileHeader
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        
                        // Account section
                        settingsSection(title: "ACCOUNT") {
                            SettingsRow(
                                icon: "at",
                                title: "Username",
                                subtitle: "@\(authManager.currentUser?.username ?? "")",
                                action: { showChangeUsername = true }
                            )
                            
                            SettingsRow(
                                icon: "person.fill",
                                title: "Display Name",
                                subtitle: authManager.currentUser?.displayName ?? "Not set",
                                action: { }
                            )
                            
                            SettingsRow(
                                icon: "envelope.fill",
                                title: "Email",
                                subtitle: authManager.currentUser?.email ?? "",
                                action: { }
                            )
                        }
                        
                        
                        // Content & Preferences section
                        settingsSection(title: "CONTENT & SETTINGS") {
                            SettingsRow(
                                icon: "bookmark",
                                title: "Bookmarks",
                                subtitle: "Saved videos",
                                action: { showBookmarks = true }
                            )
                            
                            SettingsRow(
                                icon: "bell.badge",
                                title: "Notifications",
                                subtitle: "Push notifications",
                                action: { }
                            )
                            
                            SettingsRow(
                                icon: "lock",
                                title: "Privacy",
                                subtitle: "Account privacy",
                                action: { }
                            )
                        }
                        
                        // About section
                        settingsSection(title: "ABOUT") {
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "About Rift",
                                subtitle: "Version 2.3",
                                action: { }
                            )
                            
                            SettingsRow(
                                icon: "shield.fill",
                                title: "Privacy Policy",
                                subtitle: "How we protect your data",
                                action: { }
                            )
                        }
                        
                        // Logout button
                        Button {
                            Task {
                                await authManager.logout()
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                
                                Text("Log Out")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showChangeUsername) {
            ChangeUsernameView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showBookmarks) {
            BookmarksView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        HStack(spacing: 16) {
            // Avatar
            if let avatarUrl = authManager.currentUser?.avatarUrl,
               let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 70, height: 70)
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
                    .frame(width: 70, height: 70)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.5))
                    }
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(authManager.currentUser?.displayName ?? authManager.currentUser?.username ?? "User")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    if authManager.currentUser?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(authManager.currentUser?.username ?? "")")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Settings Section
    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section title
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Section content
            VStack(spacing: 0) {
                content()
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon (minimal style)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 28)
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsRowButtonStyle())
    }
}

// MARK: - Settings Row Button Style
struct SettingsRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color.white.opacity(configuration.isPressed ? 0.05 : 0)
            )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager.shared)
}
