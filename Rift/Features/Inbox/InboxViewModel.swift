//
//  InboxViewModel.swift
//  Rift
//
//  Inbox notifications logic
//

import Foundation

@MainActor
class InboxViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Load Notifications
    func loadNotifications() async {
        // Since backend doesn't have notifications endpoint yet,
        // we'll create mock data for now
        isLoading = true
        
        // Simulate API delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock notifications
        notifications = createMockNotifications()
        
        isLoading = false
    }
    
    // MARK: - Mark as Read
    func markAsRead(notificationId: String) async {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            // Update locally for now
            print("📬 Marked notification \(notificationId) as read")
        }
    }
    
    // MARK: - Mock Data (temporary until backend is ready)
    private func createMockNotifications() -> [Notification] {
        let mockUser = User(
            id: "mock-user-1",
            username: "alex_dev",
            email: nil,
            displayName: "Alex Developer",
            bio: nil,
            avatarUrl: nil,
            isVerified: true,
            followersCount: 1500,
            followingCount: 300,
            likesCount: 5000,
            isFollowing: false,
            createdAt: nil
        )
        
        return [
            Notification(
                id: "notif-1",
                type: "like",
                message: "liked your video",
                fromUser: mockUser,
                video: nil,
                createdAt: Date().addingTimeInterval(-3600).ISO8601Format(),
                isRead: false
            ),
            Notification(
                id: "notif-2",
                type: "comment",
                message: "commented: \"Amazing video! 🔥\"",
                fromUser: mockUser,
                video: nil,
                createdAt: Date().addingTimeInterval(-7200).ISO8601Format(),
                isRead: false
            ),
            Notification(
                id: "notif-3",
                type: "follow",
                message: "started following you",
                fromUser: mockUser,
                video: nil,
                createdAt: Date().addingTimeInterval(-86400).ISO8601Format(),
                isRead: true
            )
        ]
    }
}
