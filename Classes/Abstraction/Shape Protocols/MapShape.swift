/**
 This protocol should be used on any map shape such as markers, polygons, polylines, etc. Each map provider
 should implement the custom logic for the necessary conformance.
 */
public protocol MapShape: class {

    /// Higher `zIndex` value overlays will be drawn on top of lower `zIndex` value tile layers and overlays.
    /// Equal values result in undefined draw ordering.
    var zIndex: Int32 { get set }

    /// The bounds that encompass the receiver shape.
    var bounds: CoordinateBounds? { get }
}

public extension MapShape {
    var bounds: CoordinateBounds? { return nil }
    var opacity: Float { return 1.0 }
}
