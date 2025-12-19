import MapboxMaps
import CoreLocation

/// Tool for panning and zooming the map camera to specific coordinates
struct PanMapTool {

    /// Execute pan map operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - latitude: Target latitude coordinate
    ///   - longitude: Target longitude coordinate
    ///   - zoom: Target zoom level
    ///   - animated: Whether to animate the camera movement
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        latitude: Double,
        longitude: Double,
        zoom: Double,
        animated: Bool = true
    ) -> ToolResult {
        // Validate coordinates
        guard latitude >= -90 && latitude <= 90 else {
            return .error(message: "Invalid latitude: \(latitude). Must be between -90 and 90")
        }

        guard longitude >= -180 && longitude <= 180 else {
            return .error(message: "Invalid longitude: \(longitude). Must be between -180 and 180")
        }

        // Validate zoom level
        guard zoom >= 0 && zoom <= 22 else {
            return .error(message: "Invalid zoom: \(zoom). Must be between 0 and 22")
        }

        let coordinate = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        let cameraOptions = CameraOptions(
            center: coordinate,
            zoom: zoom
        )

        // Execute camera movement
        if animated {
            mapView.camera.ease(
                to: cameraOptions,
                duration: 1.0,
                curve: .easeInOut
            ) { _ in }
        } else {
            mapView.mapboxMap.setCamera(to: cameraOptions)
        }

        return .success(data: [
            "message": "Map panned to \(latitude), \(longitude) at zoom \(zoom)",
            "latitude": latitude,
            "longitude": longitude,
            "zoom": zoom,
            "animated": animated
        ])
    }
}
