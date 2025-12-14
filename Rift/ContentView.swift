//
//  ContentView.swift
//  Rift
//
//  Main entry view - shows auth or main app based on login state
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // Check if username needs to be set up
                if needsUsernameSetup {
                    UsernameSetupView()
                        .environmentObject(authManager)
                        .interactiveDismissDisabled()
                } else {
                    // Main app
                    MainAppPlaceholderView()
                }
            } else {
                // Show auth flow
                WelcomeView()
            }
        }
    }
    
    // Check if user has temporary username (needs setup)
    private var needsUsernameSetup: Bool {
        guard let username = authManager.currentUser?.username else {
            return false
        }
        return username.hasPrefix("user_")
    }
}

// MARK: - Main App
struct MainAppPlaceholderView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager.shared)
}
