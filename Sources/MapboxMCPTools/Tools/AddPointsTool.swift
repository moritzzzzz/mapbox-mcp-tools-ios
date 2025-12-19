import MapboxMaps
import CoreLocation
import UIKit

/// Tool for adding point annotations (markers) to the map
struct AddPointsTool {

    /// Execute add points operation
    /// - Parameters:
    ///   - mapView: The MapView instance to control
    ///   - points: Array of point dictionaries with latitude, longitude, and optional title
    ///   - layerId: Unique identifier for the annotation layer
    ///   - iconImage: Optional icon image name from app bundle
    ///   - iconColor: Optional hex color code for icon tint
    ///   - iconSize: Optional icon scale factor
    /// - Returns: ToolResult indicating success or failure
    static func execute(
        on mapView: MapView,
        points: [[String: Any]],
        layerId: String,
        iconImage: String?,
        iconColor: String?,
        iconSize: Double?
    ) -> ToolResult {
        // Validate points array
        guard !points.isEmpty else {
            return .error(message: "Points array cannot be empty")
        }

        // Create or get annotation manager
        let pointAnnotationManager = mapView.annotations.makePointAnnotationManager(id: layerId)

        var pointAnnotations: [PointAnnotation] = []

        for (index, point) in points.enumerated() {
            guard let lat = point["latitude"] as? Double,
                  let lon = point["longitude"] as? Double else {
                // Skip invalid points instead of failing entirely
                continue
            }

            // Validate coordinates
            guard lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180 else {
                continue
            }

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            var annotation = PointAnnotation(coordinate: coordinate)

            // Configure icon image
            if let iconImageName = iconImage,
               let image = UIImage(named: iconImageName) {
                annotation.image = .init(image: image, name: iconImageName)
            }

            // Configure icon color
            if let colorHex = iconColor,
               let color = UIColor(hexString: colorHex) {
                annotation.iconColor = StyleColor(color)
            }

            // Configure icon size
            if let size = iconSize {
                annotation.iconSize = size
            }

            // Optional: Add text label from title field
            if let title = point["title"] as? String {
                annotation.textField = title
                annotation.textOffset = [0, -2]
                annotation.textColor = StyleColor(.black)
                annotation.textSize = 12
            }

            pointAnnotations.append(annotation)
        }

        // Validate that at least one point was processed successfully
        guard !pointAnnotations.isEmpty else {
            return .error(message: "No valid points found. Each point must have 'latitude' and 'longitude' properties")
        }

        pointAnnotationManager.annotations = pointAnnotations

        return .success(data: [
            "message": "Added \(pointAnnotations.count) point(s) to layer '\(layerId)'",
            "layerId": layerId,
            "pointCount": pointAnnotations.count
        ])
    }
}
