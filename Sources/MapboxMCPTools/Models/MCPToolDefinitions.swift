import Foundation

// MARK: - Tool Definitions

extension MCPToolDefinition {

    // MARK: 1. Pan Map to Location

    public static let panMapToLocation = MCPToolDefinition(
        name: "pan_map_to_location",
        description: "Pan and zoom the map camera to specific coordinates with optional animation",
        inputSchema: InputSchema(
            properties: [
                "latitude": Property(
                    type: "number",
                    description: "Latitude coordinate (-90 to 90)"
                ),
                "longitude": Property(
                    type: "number",
                    description: "Longitude coordinate (-180 to 180)"
                ),
                "zoom": Property(
                    type: "number",
                    description: "Zoom level (0-22, where 0 is world view and 22 is building level)"
                ),
                "animated": Property(
                    type: "boolean",
                    description: "Whether to animate the camera movement (default: true)"
                )
            ],
            required: ["latitude", "longitude", "zoom"]
        )
    )

    // MARK: 2. Add Points to Map

    public static let addPointsToMap = MCPToolDefinition(
        name: "add_points_to_map",
        description: "Add point annotations (markers) to the map with custom styling",
        inputSchema: InputSchema(
            properties: [
                "points": Property(
                    type: "array",
                    description: "Array of point objects with latitude, longitude, and optional title properties",
                    items: Property.ItemSchema(type: "object")
                ),
                "layerId": Property(
                    type: "string",
                    description: "Unique identifier for this annotation layer"
                ),
                "iconImage": Property(
                    type: "string",
                    description: "Name of the icon image asset to use (must be provided by consuming app)"
                ),
                "iconColor": Property(
                    type: "string",
                    description: "Hex color code for icon tint (e.g., '#FF0000')"
                ),
                "iconSize": Property(
                    type: "number",
                    description: "Icon scale factor (default: 1.0)"
                )
            ],
            required: ["points", "layerId"]
        )
    )

    // MARK: 3. Add Route to Map

    public static let addRouteToMap = MCPToolDefinition(
        name: "add_route_to_map",
        description: "Draw a route line between multiple coordinates",
        inputSchema: InputSchema(
            properties: [
                "coordinates": Property(
                    type: "array",
                    description: "Array of [longitude, latitude] coordinate pairs",
                    items: Property.ItemSchema(type: "array")
                ),
                "layerId": Property(
                    type: "string",
                    description: "Unique identifier for this route layer"
                ),
                "lineColor": Property(
                    type: "string",
                    description: "Hex color code for route line (e.g., '#0000FF')"
                ),
                "lineWidth": Property(
                    type: "number",
                    description: "Line width in pixels (default: 5.0)"
                )
            ],
            required: ["coordinates", "layerId"]
        )
    )

    // MARK: 4. Add Polygon to Map

    public static let addPolygonToMap = MCPToolDefinition(
        name: "add_polygon_to_map",
        description: "Add a filled polygon shape to the map",
        inputSchema: InputSchema(
            properties: [
                "coordinates": Property(
                    type: "array",
                    description: "Array of [longitude, latitude] coordinate pairs forming polygon boundary",
                    items: Property.ItemSchema(type: "array")
                ),
                "layerId": Property(
                    type: "string",
                    description: "Unique identifier for this polygon layer"
                ),
                "fillColor": Property(
                    type: "string",
                    description: "Hex color code for fill (e.g., '#00FF00')"
                ),
                "fillOpacity": Property(
                    type: "number",
                    description: "Fill opacity (0.0 to 1.0, default: 0.5)"
                ),
                "strokeColor": Property(
                    type: "string",
                    description: "Hex color code for stroke outline"
                ),
                "strokeWidth": Property(
                    type: "number",
                    description: "Stroke width in pixels (default: 2.0)"
                )
            ],
            required: ["coordinates", "layerId"]
        )
    )

    // MARK: 5. Set Map Style

    public static let setMapStyle = MCPToolDefinition(
        name: "set_map_style",
        description: "Change the map style (streets, satellite, dark, etc.)",
        inputSchema: InputSchema(
            properties: [
                "style": Property(
                    type: "string",
                    description: "Map style identifier",
                    enum: ["streets", "satellite", "satellite-streets", "dark", "light", "outdoors", "standard"]
                )
            ],
            required: ["style"]
        )
    )

    // MARK: 6. Clear Map Layers

    public static let clearMapLayers = MCPToolDefinition(
        name: "clear_map_layers",
        description: "Remove specific annotation layers or clear all custom layers",
        inputSchema: InputSchema(
            properties: [
                "layerIds": Property(
                    type: "array",
                    description: "Array of layer IDs to remove (empty array clears all custom layers)",
                    items: Property.ItemSchema(type: "string")
                )
            ],
            required: ["layerIds"]
        )
    )

    // MARK: 7. Get Map State

    public static let getMapState = MCPToolDefinition(
        name: "get_map_state",
        description: "Retrieve current map viewport information and active layers",
        inputSchema: InputSchema(
            properties: [:],  // No parameters required
            required: []
        )
    )

    // MARK: - All Tools

    /// Array of all available MCP tool definitions
    public static let allTools: [MCPToolDefinition] = [
        .panMapToLocation,
        .addPointsToMap,
        .addRouteToMap,
        .addPolygonToMap,
        .setMapStyle,
        .clearMapLayers,
        .getMapState
    ]
}
