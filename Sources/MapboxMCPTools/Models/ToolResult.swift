import Foundation

/// Result type for MCP tool execution following Swift Result pattern
public enum ToolResult {
    case success(data: [String: Any])
    case error(message: String)

    /// Convert tool result to JSON string for sending to Claude API
    /// - Returns: JSON string representation of the result
    /// - Throws: JSONSerialization error if conversion fails
    public func toJSON() throws -> String {
        let dict: [String: Any]

        switch self {
        case .success(let data):
            dict = [
                "success": true,
                "data": data
            ]
        case .error(let message):
            dict = [
                "success": false,
                "error": message
            ]
        }

        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    /// Check if result represents a successful execution
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// Check if result represents an error
    public var isError: Bool {
        if case .error = self { return true }
        return false
    }

    /// Extract success data if available
    public var successData: [String: Any]? {
        if case .success(let data) = self { return data }
        return nil
    }

    /// Extract error message if available
    public var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
