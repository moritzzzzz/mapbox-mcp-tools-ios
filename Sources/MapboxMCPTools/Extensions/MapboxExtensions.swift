import UIKit

// MARK: - UIColor Extension for Hex Color Parsing

extension UIColor {
    /// Initialize UIColor from hex string
    /// - Parameter hexString: Hex color string (e.g., "#FF0000" or "FF0000")
    /// - Returns: UIColor instance, or nil if the hex string is invalid
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove '#' prefix if present
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }

        // Validate hex length (must be 6 characters for RGB)
        guard hex.count == 6 else { return nil }

        // Parse hex string to RGB values
        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else {
            return nil
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - Coordinate Validation Utilities

extension Double {
    /// Check if value is a valid latitude (-90 to 90)
    var isValidLatitude: Bool {
        return self >= -90 && self <= 90
    }

    /// Check if value is a valid longitude (-180 to 180)
    var isValidLongitude: Bool {
        return self >= -180 && self <= 180
    }

    /// Check if value is a valid zoom level (0 to 22)
    var isValidZoom: Bool {
        return self >= 0 && self <= 22
    }

    /// Check if value is a valid opacity (0.0 to 1.0)
    var isValidOpacity: Bool {
        return self >= 0.0 && self <= 1.0
    }
}
