import MapboxMaps

/// Tool for changing the map style
struct SetStyleTool {

    /// Execute set style operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - style: Style identifier (streets, satellite, etc.)
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        style: String
    ) -> ToolResult {
        let styleURI: StyleURI

        switch style.lowercased() {
        case "streets":
            styleURI = .streets
        case "satellite":
            styleURI = .satellite
        case "satellite-streets":
            styleURI = .satelliteStreets
        case "dark":
            styleURI = .dark
        case "light":
            styleURI = .light
        case "outdoors":
            styleURI = .outdoors
        case "standard":
            styleURI = .standard
        default:
            return .error(message: "Unknown style: '\(style)'. Valid styles: streets, satellite, satellite-streets, dark, light, outdoors, standard")
        }

        mapView.mapboxMap.styleURI = styleURI

        return .success(data: [
            "message": "Map style changed to '\(style)'",
            "style": style
        ])
    }
}
