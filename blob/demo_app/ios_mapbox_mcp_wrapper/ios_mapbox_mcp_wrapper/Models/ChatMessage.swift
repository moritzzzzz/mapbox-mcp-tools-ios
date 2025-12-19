//
//  ChatMessage.swift
//  ios_mapbox_mcp_wrapper
//
//  Created by Claude Code on 19.12.25.
//

import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date

    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }

    init(role: MessageRole, content: String) {
        self.id = UUID().uuidString
        self.role = role
        self.content = content
        self.timestamp = Date()
    }
}
