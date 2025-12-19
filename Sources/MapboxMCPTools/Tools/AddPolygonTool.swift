import MapboxMaps
import CoreLocation
import UIKit

/// Tool for adding filled polygon shapes to the map
struct AddPolygonTool {

    /// Execute add polygon operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - coordinates: Array of [longitude, latitude] pairs forming the polygon boundary
    ///   - layerId: Unique identifier for the polygon layer
    ///   - fillColor: Optional hex color code for the fill
    ///   - fillOpacity: Optional fill opacity (0.0 to 1.0)
    ///   - strokeColor: Optional hex color code for the outline
    ///   - strokeWidth: Optional stroke width in pixels
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        coordinates: [[Double]],
        layerId: String,
        fillColor: String?,
        fillOpacity: Double?,
        strokeColor: String?,
        strokeWidth: Double?
    ) -> ToolResult {
        // Validate coordinates
        guard !coordinates.isEmpty else {
            return .error(message: "Coordinates array cannot be empty")
        }

        guard coordinates.count >= 3 else {
            return .error(message: "Polygon requires at least 3 coordinates")
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

        guard clCoordinates.count >= 3 else {
            return .error(message: "Polygon requires at least 3 valid coordinates. Each coordinate must be [longitude, latitude]")
        }

        // Create polygon annotation manager
        let polygonManager = mapView.annotations.makePolygonAnnotationManager(id: layerId)

        // Create polygon from coordinates
        var polygon = PolygonAnnotation(
            polygon: .init(outerRing: .init(coordinates: clCoordinates))
        )

        // Configure fill color
        if let fillColorHex = fillColor,
           let color = UIColor(hexString: fillColorHex) {
            polygon.fillColor = StyleColor(color)
        } else {
            // Default fill color
            polygon.fillColor = StyleColor(.systemGreen.withAlphaComponent(0.5))
        }

        // Configure fill opacity
        if let opacity = fillOpacity {
            // Validate opacity range
            let validOpacity = max(0.0, min(1.0, opacity))
            polygon.fillOpacity = validOpacity
        } else {
            polygon.fillOpacity = 0.5  // Default opacity
        }

        // Configure stroke color (outline)
        if let strokeColorHex = strokeColor,
           let color = UIColor(hexString: strokeColorHex) {
            polygon.fillOutlineColor = StyleColor(color)
        }

        polygonManager.annotations = [polygon]

        return .success(data: [
            "message": "Added polygon with \(clCoordinates.count) coordinate(s) to layer '\(layerId)'",
            "layerId": layerId,
            "coordinateCount": clCoordinates.count
        ])
    }
}
