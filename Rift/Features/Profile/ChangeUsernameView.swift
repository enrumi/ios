//
//  ChangeUsernameView.swift
//  Rift
//
//  Change username - Minimal 2025 style
//

import SwiftUI

struct ChangeUsernameView: View {
    @StateObject private var viewModel = ChangeUsernameViewModel()
    @State private var newUsername = ""
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Current username
                        VStack(spacing: 12) {
                            Text("Current username")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack(spacing: 8) {
                                Text("@\(authManager.currentUser?.username ?? "")")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Arrow down
                        Image(systemName: "arrow.down")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                        
                        // New username input
                        VStack(spacing: 16) {
                            Text("New username")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack(spacing: 12) {
                                Text("@")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                TextField("new_username", text: $newUsername)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .focused($isFocused)
                                    .onChange(of: newUsername) { oldValue, newValue in
                                        // Clean input
                                        let filtered = newValue.filter { $0.isLetter || $0.isNumber || $0 == "_" }
                                        if filtered != newValue {
                                            newUsername = filtered
                                        }
                                        
                                        // Check availability
                                        Task {
                                            await viewModel.checkUsername(newUsername)
                                        }
                                    }
                                
                                // Status indicator
                                if !newUsername.isEmpty {
                                    statusIndicator
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(borderColor, lineWidth: 2)
                                    )
                            )
                            
                            // Status message
                            if let message = viewModel.statusMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.isAvailable ? "checkmark.circle.fill" : "info.circle.fill")
                                        .foregroundColor(viewModel.isAvailable ? .green : .orange)
                                    
                                    Text(message)
                                        .font(.system(size: 14))
                                        .foregroundColor(viewModel.isAvailable ? .green : .orange)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Warning
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                                
                                Text("Important")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                WarningRow(text: "You can only change username once every 30 days")
                                WarningRow(text: "Your old username will be available for others")
                                WarningRow(text: "Followers will see the new username")
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        // Error message
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Save button at bottom
                VStack {
                    Spacer()
                    
                    Button {
                        Task {
                            let success = await viewModel.changeUsername(newUsername)
                            if success {
                                // Reload user data
                                if let updatedUser = viewModel.updatedUser {
                                    authManager.updateCurrentUser(updatedUser)
                                }
                                dismiss()
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Save Username")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Group {
                                if canSave {
                                    LinearGradient(
                                        colors: [.red, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                } else {
                                    Color.white.opacity(0.1)
                                }
                            }
                        )
                        .cornerRadius(16)
                    }
                    .disabled(!canSave || viewModel.isLoading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                        .offset(y: -90)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Change Username")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    // MARK: - Status Indicator
    private var statusIndicator: some View {
        Group {
            if viewModel.isChecking {
                ProgressView()
                    .tint(.white)
            } else if viewModel.isAvailable {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
        }
        .animation(.spring(response: 0.3), value: viewModel.isChecking)
    }
    
    // MARK: - Border Color
    private var borderColor: Color {
        if newUsername.isEmpty {
            return Color.white.opacity(0.1)
        } else if viewModel.isAvailable {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    // MARK: - Can Save
    private var canSave: Bool {
        !newUsername.isEmpty && 
        viewModel.isAvailable && 
        !viewModel.isChecking &&
        newUsername.lowercased() != authManager.currentUser?.username.lowercased()
    }
}

// MARK: - Warning Row
struct WarningRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundColor(.orange.opacity(0.8))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

#Preview {
    ChangeUsernameView()
        .environmentObject(AuthManager.shared)
}
