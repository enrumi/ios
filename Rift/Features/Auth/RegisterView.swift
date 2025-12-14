//
//  RegisterView.swift
//  Rift
//
//  Registration screen - TikTok style
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var displayName = ""
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
                            Text("Sign up")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Create your account")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 24)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("", text: $email)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white)
                                    .autocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .keyboardType(.emailAddress)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                            // Display Name (Optional)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name (optional)")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                TextField("", text: $displayName)
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
                        
                        // Sign Up Button
                        Button {
                            register()
                        } label: {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Text("Sign up")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(canRegister ? Color.white : Color.white.opacity(0.3))
                            .cornerRadius(4)
                        }
                        .disabled(!canRegister || isLoading)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var canRegister: Bool {
        !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    // MARK: - Actions
    private func register() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                let displayNameValue = displayName.isEmpty ? nil : displayName
                // Generate temporary username for backend (alphanumeric only, no dashes)
                let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
                let tempUsername = "user_\(uuid.prefix(8))"
                
                try await authManager.register(
                    username: tempUsername,
                    email: email,
                    password: password,
                    displayName: displayNameValue
                )
                
                isLoading = false
                
                // Close register view - ContentView will show username setup
                dismiss()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthManager.shared)
}
