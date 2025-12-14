//
//  UploadView.swift
//  Rift
//
//  Video upload flow - TikTok style
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation
import UniformTypeIdentifiers

struct UploadView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = UploadViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var caption = ""
    @State private var showCaptionSheet = false
    @FocusState private var isCaptionFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if let videoURL = viewModel.selectedVideoURL {
                    // Upload Form with Video Preview
                    uploadFormView(videoURL: videoURL)
                } else {
                    // Video Selection Screen
                    videoSelectionView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if viewModel.selectedVideoURL != nil {
                            // Go back to selection
                            viewModel.selectedVideoURL = nil
                            selectedItem = nil
                            caption = ""
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: viewModel.selectedVideoURL != nil ? "chevron.left" : "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(viewModel.selectedVideoURL != nil ? "New Post" : "Select Video")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                if viewModel.selectedVideoURL != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            Task {
                                await viewModel.uploadVideo(caption: caption)
                                if viewModel.uploadSuccess {
                                    dismiss()
                                }
                            }
                        } label: {
                            if viewModel.isUploading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Post")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                        .disabled(viewModel.isUploading)
                    }
                }
            }
        }
        .sheet(isPresented: $showCaptionSheet) {
            captionSheet
        }
    }
    
    // MARK: - Video Selection View
    private var videoSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "video.badge.plus")
                    .font(.system(size: 56))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Upload a video")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Share your creativity with the world")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Upload Button
            PhotosPicker(selection: $selectedItem, matching: .videos) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20))
                    Text("Select from Library")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(width: 240, height: 56)
                .background(Color.red)
                .cornerRadius(28)
            }
            
            Spacer()
            Spacer()
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                await viewModel.loadVideo(from: newValue)
            }
        }
    }
    
    // MARK: - Upload Form View
    private func uploadFormView(videoURL: URL) -> some View {
        ZStack {
            // Video Preview Background
            VideoPlayer(player: AVPlayer(url: videoURL))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            // Dark Overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            // Bottom Panel
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Caption Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Add caption")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(caption.count)/150")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Button {
                            showCaptionSheet = true
                        } label: {
                            HStack {
                                Text(caption.isEmpty ? "Describe your video..." : caption)
                                    .font(.system(size: 15))
                                    .foregroundColor(caption.isEmpty ? .white.opacity(0.5) : .white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                    }
                }
                .background(
                    Color(red: 0.1, green: 0.1, blue: 0.1)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
    
    // MARK: - Caption Sheet
    private var captionSheet: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.1).ignoresSafeArea()
                
                VStack {
                    TextField("Describe your video...", text: $caption, axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .lineLimit(5...10)
                        .focused($isCaptionFocused)
                        .padding()
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showCaptionSheet = false
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Add caption")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showCaptionSheet = false
                    }
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                isCaptionFocused = true
            }
        }
    }
}

#Preview {
    UploadView()
}
