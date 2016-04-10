/**
 This protocol should be used on any map shape such as markers, polygons, polylines, etc. Each map provider
 should implement the custom logic for the necessary conformance.
 */
public protocol MapAnnotation: class {

    /// The annotation that is actually added to the map provider (e.g. GMSMarker for Google Maps)
    var underlyingAnnotation: MapProviderAnnotation? { get }

    /// Higher `zIndex` value overlays will be drawn on top of lower `zIndex` value tile layers and overlays.
    /// Equal values result in undefined draw ordering.
    var zIndex: Int32 { get }
}

extension MapAnnotation {
    public var zIndex: Int32 { return 0 }
}
