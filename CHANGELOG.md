# Changelog

All notable changes to MapboxMCPTools will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-19

### Added
- Initial release of MapboxMCPTools
- 7 MCP-compliant tools for Mapbox Maps SDK v11:
  - `pan_map_to_location` - Camera navigation with coordinates and zoom
  - `add_points_to_map` - Point annotations with custom styling
  - `add_route_to_map` - Polyline routes between coordinates
  - `add_polygon_to_map` - Filled polygon shapes
  - `set_map_style` - Style switching (streets, satellite, dark, etc.)
  - `clear_map_layers` - Remove annotation layers
  - `get_map_state` - Current viewport and layer information
- Public API: `MapboxMCPTools` facade class
- Type-safe parameter extraction with Int/Double conversion
- Comprehensive error handling and validation
- Coordinate validation utilities
- Hex color parsing support
- Complete documentation and README
- MIT License

### Technical Details
- Swift 5.9+
- iOS 14.0+ support
- Mapbox Maps SDK v11.0+ dependency
- SwiftUI and UIKit compatible
- Zero additional dependencies beyond Mapbox

## [Unreleased]

### Planned
- Unit test suite
- DocC documentation
- Additional map tools (geocoding, distance calculation)
- SwiftUI view modifiers for easier integration
- Example app improvements

---

[1.0.0]: https://github.com/moritzzzzz/mapbox-mcp-tools-ios/releases/tag/1.0.0
