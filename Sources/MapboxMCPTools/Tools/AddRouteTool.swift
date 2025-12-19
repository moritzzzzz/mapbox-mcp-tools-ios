import MapboxMaps
import CoreLocation
import UIKit

/// Tool for drawing route lines on the map
struct AddRouteTool {

    /// Execute add route operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - coordinates: Array of [longitude, latitude] pairs
    ///   - layerId: Unique identifier for the route layer
    ///   - lineColor: Optional hex color code for the line
    ///   - lineWidth: Optional line width in pixels
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        coordinates: [[Double]],
        layerId: String,
        lineColor: String?,
        lineWidth: Double?
    ) -> ToolResult {
        // Validate coordinates array
        guard !coordinates.isEmpty else {
            return .error(message: "Coordinates array cannot be empty")
        }

        guard coordinates.count >= 2 else {
            return .error(message: "Route requires at least 2 coordinates")
        }

        // Convert to CLLocationCoordinate2D
        let clCoordinates = coordinates.compactMap { coord -> CLLocationCoordinate2D? in
            guard coord.count == 2 else { return nil }
            let lon = coord[0]
            let lat = coord[1]

            // Validate coordinate ranges
            guard lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180 else {
                return nil
            }

            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        guard !clCoordinates.isEmpty else {
            return .error(message: "No valid coordinates provided. Each coordinate must be [longitude, latitude]")
        }

        guard clCoordinates.count >= 2 else {
            return .error(message: "Route requires at least 2 valid coordinates")
        }

        // Create polyline annotation manager
        let polylineManager = mapView.annotations.makePolylineAnnotationManager(id: layerId)

        var polyline = PolylineAnnotation(lineCoordinates: clCoordinates)

        // Configure line color
        if let colorHex = lineColor,
           let color = UIColor(hexString: colorHex) {
            polyline.lineColor = StyleColor(color)
        } else {
            // Default color if none provided
            polyline.lineColor = StyleColor(.systemBlue)
        }

        // Configure line width
        if let width = lineWidth {
            polyline.lineWidth = width
        } else {
            polyline.lineWidth = 5.0  // Default width
        }

        polylineManager.annotations = [polyline]

        return .success(data: [
            "message": "Added route with \(clCoordinates.count) coordinate(s) to layer '\(layerId)'",
            "layerId": layerId,
            "coordinateCount": clCoordinates.count
        ])
    }
}
