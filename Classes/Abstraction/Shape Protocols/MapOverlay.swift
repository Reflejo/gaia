/**
 The `MapOverlay` protocol defines a specific type of annotation that represents both a point and an area/line
 on a map. Overlay objects are essentially data objects that contain the geographic data needed to 
 represent the map area. 

 For example, overlays can take the form of common shapes such as rectangles and circles. They can also 
 describe polygons and other complex shapes.
 */
public protocol MapOverlay: MapShape {

    /// The width of the polygon outline in screen points.
    var strokeWidth: CGFloat { get set }

    /// The color of the polygon outline.
    var strokeLineColor: UIColor { get set }
}
