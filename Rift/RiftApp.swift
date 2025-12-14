//
//  RiftApp.swift
//  Rift
//
//  TikTok Clone - iOS App Entry Point
//

import SwiftUI

@main
struct RiftApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
    }
}
