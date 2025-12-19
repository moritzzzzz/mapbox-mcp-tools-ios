import MapboxMaps

/// Tool for retrieving current map state information
struct GetMapStateTool {

    /// Execute get map state operation
    /// - Parameters:
    ///   - mapView: The MapView instance to query
    ///   - trackedLayerIds: Set of currently tracked layer IDs
    /// - Returns: ToolResult containing current map state
    static func execute(
        on mapView: MapView,
        trackedLayerIds: Set<String>
    ) -> ToolResult {
        let cameraState = mapView.mapboxMap.cameraState

        let state: [String: Any] = [
            "camera": [
                "latitude": cameraState.center.latitude,
                "longitude": cameraState.center.longitude,
                "zoom": cameraState.zoom,
                "bearing": cameraState.bearing,
                "pitch": cameraState.pitch
            ] as [String: Any],
            "style": mapView.mapboxMap.styleURI?.rawValue ?? "unknown",
            "activeLayers": Array(trackedLayerIds)
        ]

        return .success(data: state)
    }
}
