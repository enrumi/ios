//
//  WelcomeView.swift
//  Rift
//
//  Welcome screen - TikTok style
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo / App Name
                VStack(spacing: 12) {
                    Text("Rift")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Watch, Create, Connect")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.bottom, 80)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    // Sign Up Button
                    Button {
                        showRegister = true
                    } label: {
                        Text("Sign up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white)
                            .cornerRadius(4)
                    }
                    
                    // Login Button
                    Button {
                        showLogin = true
                    } label: {
                        Text("Log in")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView()
        }
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

#Preview {
    WelcomeView()
}
