//
//  NetworkManager.swift
//  Rift
//
//  Low-level network request handling
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE, PUT
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        case .noData:
            return "No data received"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Constants.API.timeout
        config.timeoutIntervalForResource = Constants.API.timeout
        self.session = URLSession(configuration: config)
        self.baseURL = Constants.API.baseURL
    }
    
    // MARK: - Main Request Method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode body if present
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        // Debug logging
        #if DEBUG
        print("🌐 \(method.rawValue) \(url.absoluteString)")
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
        #endif
        
        // Make request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        print("📡 Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Data: \(responseString)")
        }
        #endif
        
        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        case 401:
            throw NetworkError.unauthorized
            
        case 400...499:
            // Client error - try to decode error message
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message ?? errorResponse.error)
            }
            throw NetworkError.serverError("Client error: \(httpResponse.statusCode)")
            
        case 500...599:
            // Server error
            throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
            
        default:
            throw NetworkError.invalidResponse
        }
    }
    
    // MARK: - Upload File
    func uploadFile(
        to url: URL,
        data: Data,
        contentType: String
    ) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Upload failed")
        }
    }
}
