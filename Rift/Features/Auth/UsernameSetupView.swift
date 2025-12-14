//
//  UsernameSetupView.swift
//  Rift
//
//  Username setup after registration - Minimal 2025 style
//

import SwiftUI

struct UsernameSetupView: View {
    @StateObject private var viewModel = UsernameSetupViewModel()
    @State private var username = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.0, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Title
                VStack(spacing: 12) {
                    Text("Choose your")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("@username")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .overlay(
                            LinearGradient(
                                colors: [.red, .pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .mask(
                                Text("@username")
                                    .font(.system(size: 48, weight: .bold))
                            )
                        )
                }
                .padding(.bottom, 60)
                
                // Username Input
                VStack(spacing: 20) {
                    // Input field with status
                    HStack(spacing: 12) {
                        Text("@")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("username", text: $username)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isFocused)
                            .onChange(of: username) { oldValue, newValue in
                                // Clean input
                                let filtered = newValue.filter { $0.isLetter || $0.isNumber || $0 == "_" }
                                if filtered != newValue {
                                    username = filtered
                                }
                                
                                // Check availability
                                Task {
                                    await viewModel.checkUsername(username)
                                }
                            }
                        
                        // Status indicator
                        if !username.isEmpty {
                            statusIndicator
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(borderColor, lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 32)
                    
                    // Status message
                    if let message = viewModel.statusMessage {
                        HStack(spacing: 8) {
                            Image(systemName: viewModel.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.isAvailable ? .green : .red)
                            
                            Text(message)
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.isAvailable ? .green : .red)
                        }
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: viewModel.statusMessage)
                    }
                    
                    // Requirements
                    if username.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            RequirementRow(text: "3-30 characters", met: true)
                            RequirementRow(text: "Letters, numbers, underscore only", met: true)
                            RequirementRow(text: "No spaces or special characters", met: true)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                // Continue button
                Button {
                    Task {
                        await viewModel.setupUsername(username)
                    }
                } label: {
                    HStack(spacing: 12) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.system(size: 18, weight: .bold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if canContinue {
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
                .disabled(!canContinue || viewModel.isLoading)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
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
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .transition(.scale)
            } else if !username.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.red)
                    .transition(.scale)
            }
        }
        .animation(.spring(response: 0.3), value: viewModel.isChecking)
        .animation(.spring(response: 0.3), value: viewModel.isAvailable)
    }
    
    // MARK: - Border Color
    private var borderColor: Color {
        if username.isEmpty {
            return Color.white.opacity(0.1)
        } else if viewModel.isAvailable {
            return Color.green
        } else {
            return Color.red
        }
    }
    
    // MARK: - Can Continue
    private var canContinue: Bool {
        !username.isEmpty && viewModel.isAvailable && !viewModel.isChecking
    }
}

// MARK: - Requirement Row
struct RequirementRow: View {
    let text: String
    let met: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle" : "circle")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.4))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

#Preview {
    UsernameSetupView()
}
