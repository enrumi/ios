//
//  MainTabView.swift
//  Rift
//
//  Main tab bar - TikTok style (custom overlay)
//

import SwiftUI

enum Tab {
    case home, discover, upload, inbox, profile
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .home:
                    FeedView()
                case .discover:
                    DiscoverView()
                case .upload:
                    Color.clear // Upload handled differently
                case .inbox:
                    InboxView()
                case .profile:
                    ProfileView(userId: authManager.currentUser?.id ?? "")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    @State private var showUpload = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(
                icon: selectedTab == .home ? "house.fill" : "house",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            Spacer()
            
            // Discover
            TabBarButton(
                icon: selectedTab == .discover ? "safari.fill" : "safari",
                isSelected: selectedTab == .discover
            ) {
                selectedTab = .discover
            }
            
            Spacer()
            
            // Upload (center, special)
            Button {
                showUpload = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.red, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 48, height: 32)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Inbox
            TabBarButton(
                icon: selectedTab == .inbox ? "bubble.left.fill" : "bubble.left",
                isSelected: selectedTab == .inbox
            ) {
                selectedTab = .inbox
            }
            
            Spacer()
            
            // Profile
            TabBarButton(
                icon: selectedTab == .profile ? "person.fill" : "person",
                isSelected: selectedTab == .profile
            ) {
                selectedTab = .profile
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 12)
        .background(
            Color.black.opacity(0.95)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showUpload) {
            UploadView()
        }
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(width: 44, height: 44)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthManager.shared)
}
