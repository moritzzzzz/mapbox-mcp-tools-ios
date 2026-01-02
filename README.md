# MapboxMCPTools

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-14.0+-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

iOS Swift Package for wrapping Mapbox Maps SDK v11 functions into MCP (Model Context Protocol) tool definitions. This library enables natural language map control through Claude API by providing MCP-compliant tool schemas and execution handlers.

## Overview

MapboxMCPTools provides a simple interface to expose Mapbox map functionality to language models like Claude. The package wraps 7 core map operations as MCP tools that can be included in Claude API requests, allowing AI assistants to control maps through natural language.

This is the iOS equivalent of the [Android Mapbox MCP library](https://github.com/moritzzzzz/android-mapbox-map-tools-mcp-v11).

- [Javascript Mapbox MCP Tools](https://github.com/moritzzzzz/mapbox-map-tools-mcp) is the JS equivalent of this library

## Demo

Check out the [demo app](https://github.com/moritzzzzz/mapbox-mcp-tools-ios/tree/master/blob/demo_app/ios_mapbox_mcp_wrapper) to see MapboxMCPTools in action with a full Claude API integration.

## Features

- ✅ **7 MCP-compliant tools** for map control
- ✅ **Type-safe Swift API** with comprehensive error handling
- ✅ **SwiftUI and UIKit support**
- ✅ **Annotation layer management** with automatic tracking
- ✅ **Coordinate validation** and input sanitization
- ✅ **Zero external dependencies** (Mapbox SDK provided by consuming app)

## Requirements

- **iOS 14.0+**
- **Mapbox Maps SDK v11.0+**
- **Swift 5.9+**
- **Xcode 15.0+**

## Installation

### Swift Package Manager (Recommended)

#### Option 1: Via Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies**
3. Enter the repository URL:
   ```
   https://github.com/moritzzzzz/mapbox-mcp-tools-ios.git
   ```
4. Select **"Up to Next Major Version"** with `1.0.0`
5. Click **"Add Package"**
6. Select your app target and click **"Add Package"** again

#### Option 2: Via Package.swift

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/moritzzzzz/mapbox-mcp-tools-ios.git", from: "1.0.0")
]
```

Then add to your target:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MapboxMCPTools", package: "mapbox-mcp-tools-ios")
        ]
    )
]
```

### Prerequisites

Your app must already have **Mapbox Maps SDK v11** integrated:

```swift
dependencies: [
    .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0")
]
```

Get your Mapbox access token from [mapbox.com](https://account.mapbox.com/access-tokens/)

## Available MCP Tools

| Tool Name | Description | Required Parameters |
|-----------|-------------|---------------------|
| `pan_map_to_location` | Pan and zoom camera to coordinates | latitude, longitude, zoom |
| `add_points_to_map` | Add point annotations (markers) | points, layerId |
| `add_route_to_map` | Draw route line between coordinates | coordinates, layerId |
| `add_polygon_to_map` | Add filled polygon shape | coordinates, layerId |
| `set_map_style` | Change map style | style |
| `clear_map_layers` | Remove annotation layers | layerIds |
| `get_map_state` | Get current viewport and layers | (none) |

## Token Usage & Costs

Adding these 7 MCP tools to your Claude API requests uses approximately **~1,300 tokens** per request.

### Cost Breakdown

**Claude Sonnet 4.5 Pricing:**
- Input: $3.00 per 1M tokens
- Output: $15.00 per 1M tokens

**Per Request:**
- MCP tools: **~$0.0039** (1,307 tokens)
- User message (avg): **~$0.0001** (25 tokens)
- Claude response (avg): **~$0.0015** (100 tokens)
- **Total per turn: ~$0.0055** (less than 1¢)

### Usage Examples

| Scenario | API Calls | Approximate Cost |
|----------|-----------|------------------|
| 10 map operations | 10 | $0.02 |
| 100 map operations | 100 | $0.09 |
| 1,000 map operations | 1,000 | $0.65 |
| 10,000 map operations | 10,000 | $6.50 |

### Optimization Tips

**1. Use selective tools** - Include only the tools you need:
```swift
// Instead of all 7 tools (~1,300 tokens)
let allTools = mcpTools.getToolsForLLM()

// Use only navigation tools (~400 tokens)
let navTools = [
    MCPToolDefinition.panMapToLocation,
    MCPToolDefinition.setMapStyle
]
```

**2. Batch operations** - Ask Claude to perform multiple map actions in one request

**3. Use prompt caching** - Claude API's prompt caching (in beta) can cache tool definitions across requests

### Summary

The token overhead is minimal - you can make **thousands of map-related requests for just a few dollars**, making this extremely cost-effective compared to traditional map API pricing.

## Usage

### 1. Prerequisites

Your iOS app must have **Mapbox Maps SDK v11** already integrated and a `MapView` initialized.

Add Mapbox SDK to your app:
```swift
// Add to your app's Package.swift or use SPM in Xcode
.package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0")
```

### 2. Basic Setup (SwiftUI)

```swift
import SwiftUI
import MapboxMaps
import MapboxMCPTools

struct ContentView: View {
    @State private var mcpTools: MapboxMCPTools?

    var body: some View {
        Map()
            .ignoresSafeArea()
            .onMapLoaded { mapViewProxy in
                // Initialize MCP Tools when map loads
                if let mapView = mapViewProxy.mapView {
                    mcpTools = MapboxMCPTools(mapView: mapView)

                    // Get tool definitions for Claude API
                    let tools = mcpTools?.getToolsForLLM()
                    sendToolsToClaudeAPI(tools: tools)
                }
            }
    }

    func sendToolsToClaudeAPI(tools: [MCPToolDefinition]?) {
        // Implement your Claude API integration here
    }
}
```

### 3. Basic Setup (UIKit)

```swift
import UIKit
import MapboxMaps
import MapboxMCPTools

class MapViewController: UIViewController {
    var mapView: MapView!
    var mcpTools: MapboxMCPTools!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Mapbox MapView
        let cameraOptions = CameraOptions(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            zoom: 12
        )

        mapView = MapView(
            frame: view.bounds,
            mapInitOptions: MapInitOptions(
                cameraOptions: cameraOptions,
                styleURI: .streets
            )
        )
        view.addSubview(mapView)

        // Initialize MCP Tools
        mcpTools = MapboxMCPTools(mapView: mapView)

        // Get tool definitions for Claude API
        let tools = mcpTools.getToolsForLLM()
        print("Available tools: \(tools.count)")
    }
}
```

### 4. Getting Tool Definitions

```swift
// Get as Swift array
let tools: [MCPToolDefinition] = mcpTools.getToolsForLLM()

// Get as JSON string for API requests
if let toolsJSON = try? mcpTools.getToolsJSON() {
    print(toolsJSON)
}
```

### 5. Executing Tools

When Claude responds with a tool call, execute it using the `executeTool` method:

```swift
func handleClaudeResponse(toolName: String, parameters: [String: Any]) {
    let result = mcpTools.executeTool(name: toolName, params: parameters)

    switch result {
    case .success(let data):
        print("✅ Success: \(data)")
        // Update UI or send result back to Claude

    case .error(let message):
        print("❌ Error: \(message)")
        // Handle error in UI
    }
}
```

## Tool Examples

### Pan Map to Location

```swift
let result = mcpTools.executeTool(
    name: "pan_map_to_location",
    params: [
        "latitude": 40.7128,
        "longitude": -74.0060,
        "zoom": 14.0,
        "animated": true
    ]
)
```

### Add Points (Markers)

```swift
let result = mcpTools.executeTool(
    name: "add_points_to_map",
    params: [
        "points": [
            ["latitude": 40.7128, "longitude": -74.0060, "title": "New York"],
            ["latitude": 34.0522, "longitude": -118.2437, "title": "Los Angeles"]
        ],
        "layerId": "cities",
        "iconColor": "#FF0000",
        "iconSize": 1.5
    ]
)
```

### Add Route Line

```swift
let result = mcpTools.executeTool(
    name: "add_route_to_map",
    params: [
        "coordinates": [
            [-74.0060, 40.7128],  // [longitude, latitude]
            [-118.2437, 34.0522]
        ],
        "layerId": "route1",
        "lineColor": "#0000FF",
        "lineWidth": 5.0
    ]
)
```

### Add Polygon

```swift
let result = mcpTools.executeTool(
    name: "add_polygon_to_map",
    params: [
        "coordinates": [
            [-74.0, 40.7],
            [-73.9, 40.7],
            [-73.9, 40.8],
            [-74.0, 40.8],
            [-74.0, 40.7]  // Close the polygon
        ],
        "layerId": "area1",
        "fillColor": "#00FF00",
        "fillOpacity": 0.3,
        "strokeColor": "#006600",
        "strokeWidth": 2.0
    ]
)
```

### Set Map Style

```swift
let result = mcpTools.executeTool(
    name: "set_map_style",
    params: ["style": "satellite"]
)

// Available styles: streets, satellite, satellite-streets, dark, light, outdoors, standard
```

### Clear Layers

```swift
// Clear specific layers
let result = mcpTools.executeTool(
    name: "clear_map_layers",
    params: ["layerIds": ["cities", "route1"]]
)

// Clear all layers
let result = mcpTools.executeTool(
    name: "clear_map_layers",
    params: ["layerIds": []]
)
```

### Get Map State

```swift
let result = mcpTools.executeTool(
    name: "get_map_state",
    params: [:]
)

// Returns camera position, style, and active layers
```

## Integration with Claude API

Example of integrating with Claude API (using Anthropic SDK):

```swift
import Anthropic

func sendMapToolsToClaudeAPI() async {
    let client = Anthropic(apiKey: "your-api-key")

    // Get MCP tool definitions
    let tools = mcpTools.getToolsForLLM()

    // Convert to Claude API format
    let claudeTools = tools.map { tool in
        Tool(
            name: tool.name,
            description: tool.description,
            inputSchema: tool.inputSchema
        )
    }

    // Send request with tools
    let response = try await client.messages.create(
        model: "claude-3-5-sonnet-20241022",
        maxTokens: 1024,
        messages: [
            Message(role: .user, content: "Show me New York City on the map")
        ],
        tools: claudeTools
    )

    // Handle tool use response
    if let toolUse = response.content.first?.toolUse {
        let result = mcpTools.executeTool(
            name: toolUse.name,
            params: toolUse.input
        )

        // Send result back to Claude if needed
        print(result)
    }
}
```

## Architecture

```
┌─────────────────────────┐
│   Your iOS App          │
│  (SwiftUI or UIKit)     │
└───────────┬─────────────┘
            │
            │ MapView reference
            ▼
┌─────────────────────────┐
│  MapboxMCPTools         │
│  (Facade)               │
├─────────────────────────┤
│ • getToolsForLLM()      │
│ • executeTool()         │
└───────────┬─────────────┘
            │
            │ Dispatch to tools
            ▼
┌─────────────────────────┐
│  Individual Tools       │
│  • PanMapTool           │
│  • AddPointsTool        │
│  • AddRouteTool         │
│  • ... etc              │
└───────────┬─────────────┘
            │
            │ Mapbox SDK calls
            ▼
┌─────────────────────────┐
│  Mapbox Maps SDK v11    │
│  (MapView)              │
└─────────────────────────┘
```

## Error Handling

All tools return a `ToolResult` enum:

```swift
public enum ToolResult {
    case success(data: [String: Any])
    case error(message: String)
}
```

Common error scenarios:
- Invalid coordinates (out of range)
- Invalid zoom level (not 0-22)
- Missing required parameters
- Invalid color format (not hex)
- MapView deallocated
- Insufficient coordinates for polygons/routes

## Best Practices

1. **Always initialize after map loads**: Ensure the MapView is fully initialized before creating `MapboxMCPTools`
2. **Use unique layer IDs**: Each annotation layer needs a unique identifier
3. **Validate Claude responses**: Check tool names and parameters before execution
4. **Handle errors gracefully**: Display error messages to users when tool execution fails
5. **Track layer cleanup**: Use `clear_map_layers` to remove annotations when no longer needed
6. **Coordinate format**: Use [longitude, latitude] order for routes and polygons (GeoJSON standard)

## Limitations

- Icon images for point annotations must be included in the consuming app's bundle
- No support for custom MapView subclasses
- Thread safety: All operations run on the main thread (required by Mapbox SDK)
- Style changes may reset custom layers (Mapbox SDK behavior)

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Related Projects

- [Android Mapbox MCP Tools](https://github.com/moritzzzzz/android-mapbox-map-tools-mcp-v11) - Android equivalent of this library
- [Javascript Mapbox MCP Tools](https://github.com/moritzzzzz/mapbox-map-tools-mcp) - JS equivalent of this library

## Support

For issues and questions:
- File an issue on GitHub
- Check Mapbox documentation: https://docs.mapbox.com/ios/maps/
- MCP specification: https://spec.modelcontextprotocol.io/

## Acknowledgments

This library wraps the excellent [Mapbox Maps SDK for iOS](https://github.com/mapbox/mapbox-maps-ios) and follows the [Model Context Protocol](https://modelcontextprotocol.io/) specification.
