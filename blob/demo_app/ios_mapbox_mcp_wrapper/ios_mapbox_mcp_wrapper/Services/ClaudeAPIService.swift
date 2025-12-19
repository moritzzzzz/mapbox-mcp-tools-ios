//
//  ClaudeAPIService.swift
//  ios_mapbox_mcp_wrapper
//
//  Created by Claude Code on 19.12.25.
//

import Foundation
import MapboxMCPTools

class ClaudeAPIService {

    private let apiKey: String
    private let baseURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-sonnet-4-5"

    init() {
        // Load API key from Info.plist
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ClaudeAPIKey") as? String else {
            fatalError("ClaudeAPIKey not found in Info.plist")
        }
        self.apiKey = key
    }

    // MARK: - API Request

    func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage],
        tools: [MCPToolDefinition]
    ) async throws -> ClaudeResponse {

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        // Build messages array from conversation history
        var messages: [[String: Any]] = []

        // Add conversation history
        for msg in conversationHistory {
            if msg.role != .system {
                messages.append([
                    "role": msg.role.rawValue,
                    "content": msg.content
                ])
            }
        }

        // Add new user message
        messages.append([
            "role": "user",
            "content": userMessage
        ])

        // Convert MCP tools to Claude API format
        let toolsJSON = tools.map { tool -> [String: Any] in
            return [
                "name": tool.name,
                "description": tool.description,
                "input_schema": [
                    "type": tool.inputSchema.type,
                    "properties": tool.inputSchema.properties.mapValues { property -> [String: Any] in
                        var dict: [String: Any] = [
                            "type": property.type,
                            "description": property.description
                        ]
                        if let items = property.items {
                            dict["items"] = ["type": items.type]
                        }
                        if let enumValues = property.enum {
                            dict["enum"] = enumValues
                        }
                        return dict
                    },
                    "required": tool.inputSchema.required
                ]
            ]
        }

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "messages": messages,
            "tools": toolsJSON
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        print("🔵 Sending request to Claude API...")
        print("📤 User message: \(userMessage)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeAPIError.invalidResponse
        }

        print("📥 Response status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error: \(errorBody)")
            throw ClaudeAPIError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        print("✅ Received response from Claude")

        return claudeResponse
    }
}

// MARK: - Response Models

struct ClaudeResponse: Codable {
    let id: String
    let type: String
    let role: String
    let content: [ContentBlock]
    let model: String
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case id, type, role, content, model
        case stopReason = "stop_reason"
    }
}

struct ContentBlock: Codable {
    let type: String
    let text: String?
    let id: String?
    let name: String?
    let input: [String: AnyCodable]?

    var isToolUse: Bool {
        return type == "tool_use"
    }
}

// MARK: - AnyCodable for dynamic JSON

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }

    /// Recursively unwrap AnyCodable to native Swift types
    func unwrapped() -> Any {
        switch value {
        case let array as [Any]:
            return array.map { item in
                if let codable = item as? AnyCodable {
                    return codable.unwrapped()
                }
                return item
            }
        case let dict as [String: Any]:
            return dict.mapValues { item in
                if let codable = item as? AnyCodable {
                    return codable.unwrapped()
                }
                return item
            }
        default:
            return value
        }
    }
}

extension Dictionary where Key == String, Value == AnyCodable {
    /// Convert dictionary of AnyCodable to dictionary of Any, unwrapping nested structures
    func toAnyDictionary() -> [String: Any] {
        return self.mapValues { $0.unwrapped() }
    }
}

// MARK: - Error Types

enum ClaudeAPIError: LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Claude API"
        case .apiError(let statusCode, let message):
            return "API Error (\(statusCode)): \(message)"
        }
    }
}
