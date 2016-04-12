import CoreLocation

/**
 The `MapShape` protocol defines a specific type of annotation that represents both a point and an area
 on a map. Overlay objects are essentially data objects that contain the geographic data needed to 
 represent the map area. 

 For example, overlays can take the form of common shapes such as rectangles and circles. They can also 
 describe polygons and other complex shapes.
 */
public protocol MapShape: MapAnnotation {

    /// The width of the polygon outline in screen points.
    var strokeWidth: CGFloat { get }

    /// The color of the polygon outline.
    var strokeColor: UIColor { get }

    /// This bound defines the wrapped rectangle that surrounds the shape
    var bounds: CoordinateBounds { get }
}
