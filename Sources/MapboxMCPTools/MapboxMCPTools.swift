import Foundation
import MapboxMaps

/// Main facade for Mapbox MCP Tools
/// Provides MCP tool definitions and execution interface for consuming applications
public final class MapboxMCPTools {

    // MARK: - Properties

    private weak var mapView: MapView?
    private var trackedLayerIds: Set<String> = []

    // MARK: - Initialization

    /// Initialize with a MapView instance
    /// - Parameter mapView: The MapView to control (must have Mapbox SDK initialized)
    public init(mapView: MapView) {
        self.mapView = mapView
    }

    // MARK: - Tool Definitions

    /// Get all MCP tool definitions for sending to Claude API
    /// - Returns: Array of tool definitions conforming to MCP specification
    public func getToolsForLLM() -> [MCPToolDefinition] {
        return MCPToolDefinition.allTools
    }

    /// Get tool definitions as JSON string
    /// - Returns: JSON string representation of all tools
    /// - Throws: Encoding error if JSON serialization fails
    public func getToolsJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(MCPToolDefinition.allTools)
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    // MARK: - Tool Execution

    /// Execute a tool by name with parameters
    /// - Parameters:
    ///   - name: Tool name from MCP tool definition
    ///   - params: Dictionary of parameters from Claude API response
    /// - Returns: ToolResult indicating success or error
    public func executeTool(name: String, params: [String: Any]) -> ToolResult {
        guard let mapView = mapView else {
            return .error(message: "MapView instance is nil or deallocated")
        }

        // Dispatcher routes to appropriate tool handler
        switch name {
        case "pan_map_to_location":
            return executePanMap(mapView: mapView, params: params)

        case "add_points_to_map":
            return executeAddPoints(mapView: mapView, params: params)

        case "add_route_to_map":
            return executeAddRoute(mapView: mapView, params: params)

        case "add_polygon_to_map":
            return executeAddPolygon(mapView: mapView, params: params)

        case "set_map_style":
            return executeSetStyle(mapView: mapView, params: params)

        case "clear_map_layers":
            return executeClearLayers(mapView: mapView, params: params)

        case "get_map_state":
            return executeGetMapState(mapView: mapView)

        default:
            return .error(message: "Unknown tool: \(name)")
        }
    }

    // MARK: - Private Execution Methods

    private func executePanMap(mapView: MapView, params: [String: Any]) -> ToolResult {
        guard let lat = extractDouble(from: params, key: "latitude"),
              let lon = extractDouble(from: params, key: "longitude"),
              let zoom = extractDouble(from: params, key: "zoom") else {
            return .error(message: "Missing required parameters: latitude, longitude, zoom")
        }

        let animated = params["animated"] as? Bool ?? true

        return PanMapTool.execute(
            on: mapView,
            latitude: lat,
            longitude: lon,
            zoom: zoom,
            animated: animated
        )
    }

    private func executeAddPoints(mapView: MapView, params: [String: Any]) -> ToolResult {
        guard let points = params["points"] as? [[String: Any]],
              let layerId = params["layerId"] as? String else {
            return .error(message: "Missing required parameters: points, layerId")
        }

        trackedLayerIds.insert(layerId)

        return AddPointsTool.execute(
            on: mapView,
            points: points,
            layerId: layerId,
            iconImage: params["iconImage"] as? String,
            iconColor: params["iconColor"] as? String,
            iconSize: extractDouble(from: params, key: "iconSize")
        )
    }

    private func executeAddRoute(mapView: MapView, params: [String: Any]) -> ToolResult {
        guard let coordinatesRaw = params["coordinates"] as? [[Any]],
              let layerId = params["layerId"] as? String else {
            return .error(message: "Missing required parameters: coordinates, layerId")
        }

        // Convert [[Any]] to [[Double]]
        let coordinates = coordinatesRaw.compactMap { coord -> [Double]? in
            let doubles = coord.compactMap { value -> Double? in
                if let double = value as? Double {
                    return double
                } else if let int = value as? Int {
                    return Double(int)
                }
                return nil
            }
            return doubles.count == 2 ? doubles : nil
        }

        guard !coordinates.isEmpty else {
            return .error(message: "Invalid coordinates format")
        }

        trackedLayerIds.insert(layerId)

        return AddRouteTool.execute(
            on: mapView,
            coordinates: coordinates,
            layerId: layerId,
            lineColor: params["lineColor"] as? String,
            lineWidth: extractDouble(from: params, key: "lineWidth")
        )
    }

    private func executeAddPolygon(mapView: MapView, params: [String: Any]) -> ToolResult {
        guard let coordinatesRaw = params["coordinates"] as? [[Any]],
              let layerId = params["layerId"] as? String else {
            return .error(message: "Missing required parameters: coordinates, layerId")
        }

        // Convert [[Any]] to [[Double]]
        let coordinates = coordinatesRaw.compactMap { coord -> [Double]? in
            let doubles = coord.compactMap { value -> Double? in
                if let double = value as? Double {
                    return double
                } else if let int = value as? Int {
                    return Double(int)
                }
                return nil
            }
            return doubles.count == 2 ? doubles : nil
        }

        guard !coordinates.isEmpty else {
            return .error(message: "Invalid coordinates format")
        }

        trackedLayerIds.insert(layerId)

        return AddPolygonTool.execute(
            on: mapView,
            coordinates: coordinates,
            layerId: layerId,
            fillColor: params["fillColor"] as? String,
            fillOpacity: extractDouble(from: params, key: "fillOpacity"),
            strokeColor: params["strokeColor"] as? String,
            strokeWidth: extractDouble(from: params, key: "strokeWidth")
        )
    }

    private func executeSetStyle(mapView: MapView, params: [String: Any]) -> ToolResult {
        guard let style = params["style"] as? String else {
            return .error(message: "Missing required parameter: style")
        }

        return SetStyleTool.execute(on: mapView, style: style)
    }

    private func executeClearLayers(mapView: MapView, params: [String: Any]) -> ToolResult {
        let layerIds = params["layerIds"] as? [String] ?? []

        return ClearLayersTool.execute(
            on: mapView,
            layerIds: layerIds,
            trackedLayerIds: &trackedLayerIds
        )
    }

    private func executeGetMapState(mapView: MapView) -> ToolResult {
        return GetMapStateTool.execute(
            on: mapView,
            trackedLayerIds: trackedLayerIds
        )
    }

    // MARK: - Helper Methods

    /// Extract a Double value from parameters, handling both Int and Double types
    private func extractDouble(from params: [String: Any], key: String) -> Double? {
        if let double = params[key] as? Double {
            return double
        } else if let int = params[key] as? Int {
            return Double(int)
        }
        return nil
    }
}
