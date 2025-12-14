//
//  Constants.swift
//  Rift
//
//  App-wide constants and configuration
//

import Foundation

enum Constants {
    // MARK: - API Configuration
    enum API {
        // Backend server IP (change to your machine's IP for real device testing)
        static let baseURL = "http://192.168.1.109:3000"
        static let timeout: TimeInterval = 30
        
        // Endpoints
        enum Endpoints {
            // Auth
            static let register = "/auth/register"
            static let login = "/auth/login"
            static let refresh = "/auth/refresh"
            static let logout = "/auth/logout"
            
            // Users
            static let me = "/users/me"
            static let users = "/users"
            
            // Videos
            static let videos = "/videos"
            
            // Feed
            static let forYou = "/feed/for-you"
            static let following = "/feed/following"
            
            // Interactions
            static let likes = "/interactions/likes"
            static let comments = "/interactions/comments"
            static let follows = "/interactions/follows"
            
            // Search
            static let search = "/search"
            
            // Upload
            static let presign = "/upload/presign"
        }
    }
    
    // MARK: - Keychain Keys
    enum Keychain {
        static let accessToken = "rift.accessToken"
        static let refreshToken = "rift.refreshToken"
        static let userId = "rift.userId"
    }
    
    // MARK: - UI Configuration
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        
        // Colors
        static let primaryCyan = "00D9FF"
        static let primaryPurple = "9D4EDD"
        static let backgroundBlack = "0A0A0A"
    }
}
