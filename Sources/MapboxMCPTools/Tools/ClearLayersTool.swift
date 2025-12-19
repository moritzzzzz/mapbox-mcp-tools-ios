import MapboxMaps

/// Tool for clearing annotation layers from the map
struct ClearLayersTool {

    /// Execute clear layers operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - layerIds: Array of layer IDs to remove (empty array clears all tracked layers)
    ///   - trackedLayerIds: Set of currently tracked layer IDs (will be modified)
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        layerIds: [String],
        trackedLayerIds: inout Set<String>
    ) -> ToolResult {
        var removedLayers: [String] = []

        if layerIds.isEmpty {
            // Clear all tracked layers
            for layerId in trackedLayerIds {
                mapView.annotations.removeAnnotationManager(withId: layerId)
                removedLayers.append(layerId)
            }
            trackedLayerIds.removeAll()
        } else {
            // Clear specific layers
            for layerId in layerIds {
                if trackedLayerIds.contains(layerId) {
                    mapView.annotations.removeAnnotationManager(withId: layerId)
                    trackedLayerIds.remove(layerId)
                    removedLayers.append(layerId)
                }
            }
        }

        let message = removedLayers.isEmpty
            ? "No layers to remove"
            : "Removed \(removedLayers.count) layer(s)"

        return .success(data: [
            "message": message,
            "removedLayers": removedLayers,
            "remainingLayers": Array(trackedLayerIds)
        ])
    }
}
