import CoreLocation

/**
 A circle on the Earth's surface (spherical cap).
 */
public protocol MapCircle: MapShape {

    /// Position on Earth of circle center.
    var position: CLLocationCoordinate2D { get set }

    /// Radius of the circle in meters; must be positive.
    var radius: CLLocationDistance { get set }

    /// The width of the circle's outline in screen points. Defaults to 1.
    /// Setting strokeWidth to 0 results in no stroke.
    var strokeWidth: CGFloat { get set }

    /// The color of this circle's outline. The default value is black.
    var strokeLineColor: UIColor { get set }

    /**
     Convenience constructor for MapCircle conformers for a particular position and radius.

     - parameter position: The position on earth of circle center.
     - parameter radius:   The radius of the circle in meters.
     */
    init(position: CLLocationCoordinate2D, radius: CLLocationDistance)
}
