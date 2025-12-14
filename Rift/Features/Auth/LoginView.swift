//
//  LoginView.swift
//  Rift
//
//  Login screen - TikTok style
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Log in")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 24)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Username
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("", text: $username)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                SecureField("", text: $password)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Login Button
                        Button {
                            login()
                        } label: {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Text("Log in")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canLogin ? Color.white : Color.white.opacity(0.3))
                            .cornerRadius(4)
                        }
                        .disabled(!canLogin || isLoading)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canLogin: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    // MARK: - Actions
    private func login() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                try await authManager.login(username: username, password: password)
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
