//
//  UploadViewModel.swift
//  Rift
//
//  Upload business logic
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation
import CoreTransferable

@MainActor
class UploadViewModel: ObservableObject {
    @Published var selectedVideoURL: URL?
    @Published var isUploading = false
    @Published var uploadSuccess = false
    @Published var errorMessage: String?
    
    // MARK: - Load Video from PhotosPicker
    func loadVideo(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            guard let movie = try await item.loadTransferable(type: VideoTransferable.self) else {
                errorMessage = "Failed to load video"
                return
            }
            
            selectedVideoURL = movie.url
        } catch {
            errorMessage = "Failed to load video: \(error.localizedDescription)"
            print("❌ Failed to load video: \(error)")
        }
    }
    
    // MARK: - Upload Video
    func uploadVideo(caption: String) async {
        guard let videoURL = selectedVideoURL else { return }
        
        isUploading = true
        errorMessage = nil
        
        do {
            // 1. Get video data
            let videoData = try Data(contentsOf: videoURL)
            
            // 2. Get presigned URL
            let presignedResponse: PresignedURLResponse = try await APIService.shared.getPresignedUploadURL(
                filename: "video_\(UUID().uuidString).mp4",
                type: "video"
            )
            
            // 3. Upload video to presigned URL
            guard let uploadURL = URL(string: presignedResponse.uploadUrl) else {
                throw NSError(domain: "Invalid upload URL", code: -1)
            }
            
            try await APIService.shared.uploadFile(
                to: uploadURL,
                data: videoData,
                contentType: "video/mp4"
            )
            
            // 4. Get video duration
            let asset = AVAsset(url: videoURL)
            let duration = try await asset.load(.duration)
            let durationInSeconds = Int(CMTimeGetSeconds(duration))
            
            // 5. Create video record
            struct CreateVideoRequest: Codable {
                let caption: String?
                let videoUrl: String
                let duration: Int
            }
            
            let _: Video = try await APIService.shared.request(
                endpoint: Constants.API.Endpoints.videos,
                method: .POST,
                body: CreateVideoRequest(
                    caption: caption.isEmpty ? nil : caption,
                    videoUrl: presignedResponse.publicUrl,
                    duration: durationInSeconds
                ),
                requiresAuth: true
            )
            
            isUploading = false
            uploadSuccess = true
        } catch {
            isUploading = false
            
            // Better error message
            if let decodingError = error as? DecodingError {
                errorMessage = "Failed to process server response"
                print("❌ Decoding error: \(decodingError)")
            } else {
                errorMessage = error.localizedDescription
            }
            
            print("❌ Upload failed: \(error)")
        }
    }
}

// MARK: - Video Transferable
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let originalFile = received.file
            let uniqueFile = URL.temporaryDirectory.appending(component: "\(UUID().uuidString).mov")
            try FileManager.default.copyItem(at: originalFile, to: uniqueFile)
            return Self(url: uniqueFile)
        }
    }
}
