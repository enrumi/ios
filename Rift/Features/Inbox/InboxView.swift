//
//  InboxView.swift
//  Rift
//
//  Inbox/Notifications - placeholder
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "bell")
                    .font(.system(size: 64))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("Inbox")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Notifications coming soon")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    InboxView()
}
