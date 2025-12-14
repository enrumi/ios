//
//  InboxView.swift
//  Rift
//
//  Inbox/Notifications
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.notifications.isEmpty && !viewModel.isLoading {
                    emptyState
                } else {
                    notificationsList
                }
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadNotifications()
            }
        }
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.notifications) { notification in
                    NotificationRow(notification: notification)
                        .onTapGesture {
                            Task {
                                await viewModel.markAsRead(notificationId: notification.id)
                            }
                        }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No notifications yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("When someone likes or comments on your videos, you'll see it here")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            if let avatarUrl = notification.fromUser?.avatarUrl {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: notificationIcon)
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    )
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(notification.fromUser?.username ?? "Someone")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(notification.message)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text(timeAgo(from: notification.createdAt))
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Type icon
            Image(systemName: notificationIcon)
                .font(.system(size: 20))
                .foregroundColor(notificationColor)
                .padding(8)
                .background(notificationColor.opacity(0.15))
                .clipShape(Circle())
            
            // Unread indicator
            if notification.isRead == false {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(notification.isRead == false ? Color.white.opacity(0.03) : Color.clear)
    }
    
    private var notificationIcon: String {
        switch notification.type {
        case "like": return "heart.fill"
        case "comment": return "bubble.right.fill"
        case "follow": return "person.fill.badge.plus"
        default: return "bell.fill"
        }
    }
    
    private var notificationColor: Color {
        switch notification.type {
        case "like": return .red
        case "comment": return .blue
        case "follow": return .purple
        default: return .gray
        }
    }
    
    private func timeAgo(from dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Just now"
        }
        
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(seconds / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    InboxView()
}
