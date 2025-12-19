import Foundation

/// Represents an MCP tool definition conforming to Model Context Protocol specification
public struct MCPToolDefinition: Codable {
    public let name: String
    public let description: String
    public let inputSchema: InputSchema

    public init(name: String, description: String, inputSchema: InputSchema) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }

    /// JSON Schema for tool input parameters
    public struct InputSchema: Codable {
        public let type: String
        public let properties: [String: Property]
        public let required: [String]

        public init(type: String = "object", properties: [String: Property], required: [String]) {
            self.type = type
            self.properties = properties
            self.required = required
        }
    }

    /// Schema property definition for a single parameter
    public struct Property: Codable {
        public let type: String
        public let description: String
        public let items: ItemSchema?
        public let `enum`: [String]?

        public init(type: String, description: String, items: ItemSchema? = nil, enum: [String]? = nil) {
            self.type = type
            self.description = description
            self.items = items
            self.enum = `enum`
        }

        /// Schema for array items
        public struct ItemSchema: Codable {
            public let type: String

            public init(type: String) {
                self.type = type
            }
        }
    }
}

// MARK: - JSON Serialization

public extension MCPToolDefinition {
    /// Convert tool definition to JSON string
    /// - Returns: Pretty-printed JSON string
    /// - Throws: Encoding error if conversion fails
    func toJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
