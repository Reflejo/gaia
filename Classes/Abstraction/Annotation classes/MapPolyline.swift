import CoreLocation

/**
 `MapPolyline` specifies the available options for a polyline that exists on the Earth's surface.
 It is drawn as a physical line between the points specified in |path|.
 */
public class MapPolyline: MapShape {

    /// An array containing all the waypoints (i.e. GPS positions) on the shape
    public let coordinates: [CLLocationCoordinate2D]

    public weak var underlyingAnnotation: MapProviderAnnotation?
    public let strokeWidth: CGFloat
    public let strokeColor: UIColor
    public var bounds: CoordinateBounds {
        return CoordinateBounds(includingCoordinates: self.coordinates)
    }

    /**
     Creates a polyline from an encoded path.

     - parameter encodedPath: The encoded path using Google's Encoded Polyline Algorithm Format.
     - parameter strokeWidth: The line width in points (default 1).
     - parameter strokeColor: The color of the stroke (default black).
     */
    public convenience init?(encodedPath: String, strokeWidth: CGFloat = 1.0,
                             strokeColor: UIColor = .blackColor())
    {
        guard let coordinates = MapPath.decodePoints(encodedPath) else {
            return nil
        }

        self.init(coordinates: coordinates, strokeWidth: strokeWidth, strokeColor: strokeColor)
    }

    /**
     Creates a polyline from an array of coordinates

     - parameter coordinates: An array of coordinates that will define the closed path.
     - parameter strokeWidth: The line width in points (default 1).
     - parameter strokeColor: The color of the stroke (default black).
     */
    public init(coordinates: [CLLocationCoordinate2D], strokeWidth: CGFloat = 1.0,
                strokeColor: UIColor = .blackColor())
    {
        self.coordinates = coordinates
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
    }
}
