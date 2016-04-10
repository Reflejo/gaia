import CoreLocation

/**
 A circle on the Earth's surface (spherical cap).
 */
public class MapCircle: MapShape {

    /// Position on Earth of circle center.
    public let position: CLLocationCoordinate2D

    /// Radius of the circle in meters; must be positive.
    public let radius: CLLocationDistance

    /// The color of this circle's filling. The default value is blue.
    public let fillColor: UIColor

    public let zIndex: Int32
    public let strokeWidth: CGFloat
    public let strokeColor: UIColor
    public weak var underlyingAnnotation: MapProviderAnnotation?
    public var bounds: CoordinateBounds {
        let northWest = MapUtils.offset(from: self.position, distance: self.radius, heading: 315)
        let northEast = MapUtils.offset(from: self.position, distance: self.radius, heading: 135)
        return CoordinateBounds(coordinate: northWest, coordinate: northEast)
    }

    /**
     Convenience constructor for MapCircle conformers for a particular position and radius.

     - parameter position: The position on earth of circle center.
     - parameter radius:   The radius of the circle in meters.
     */
    init(position: CLLocationCoordinate2D, radius: CLLocationDistance, zIndex: Int32 = 0,
         strokeWidth: CGFloat = 1.0, strokeColor: UIColor = .blackColor(), fillColor: UIColor = .blueColor())
    {
        self.position = position
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.zIndex = zIndex
    }
}
