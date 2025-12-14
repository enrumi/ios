//
//  Comment.swift
//  Rift
//
//  Comment model (extracted from Models.swift for clarity)
//

import Foundation

struct Comment: Codable, Identifiable {
    let id: String
    let videoId: String
    let userId: String
    let text: String
    let createdAt: String
    let user: User?
}
