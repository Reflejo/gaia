import CoreLocation

/**
 MapPolygon defines a polygon that appears on the map. A polygon (like a polyline) defines a
 series of connected coordinates in an ordered sequence; additionally, polygons form a closed loop
 and define a filled region.
 */
public class MapPolygon: MapShape {

    /// An array containing all the waypoints (i.e. GPS positions) on the shape
    let coordinates: [CLLocationCoordinate2D]

    /// The color of the polygon filling.
    let fillColor: UIColor

    public weak var underlyingAnnotation: MapProviderAnnotation?
    public let strokeWidth: CGFloat
    public let strokeColor: UIColor
    public var bounds: CoordinateBounds {
        return CoordinateBounds(includingCoordinates: self.coordinates)
    }

    /**
     Returns whether the given point lies inside the receiver. Inside is defined as not containing the
     South Pole. The South Pole is always outside. The polygon is formed of great circle segments if
     geodesic is true, and of rhumb (loxodromic) segments otherwise.

     - parameter position: The point that may be contained within the specified polygon.
     - parameter geodesic: A boolean indicating if the polygon is formed of great circle segments.

     - returns: a boolean indicating if the position is inside the polygon.
     */
    func containsPosition(position: CLLocationCoordinate2D, geodesic: Bool = false) -> Bool {
        guard let lastPosition = self.coordinates.last else {
            return false
        }

        let φ = position.longitude * DegreesToRadians
        let λ = position.latitude * DegreesToRadians

        var previousφ = lastPosition.longitude * DegreesToRadians
        var previousλ = lastPosition.latitude * DegreesToRadians
        var verticesIntersected = 0
        for point in self.coordinates {
            let Δλ = max(min(φ - previousφ, M_PI), -M_PI)

            // If the point is right on the vertex we assume it's inside the polygon.
            if λ == previousλ && Δλ == 0 {
                return true
            }

            let currentλ = point.latitude * DegreesToRadians
            let currentφ = point.longitude * DegreesToRadians

            let Δcurrentλ = max(min(currentφ - previousφ, M_PI), -M_PI)

            // Offset longitudes by -previousLongtiude.
            if MapUtils.intersects(previousλ, latitude2: currentλ, longitude2: Δcurrentλ,
                                   latitude3: λ, longitude3: Δλ, geodesic: geodesic)
            {
                verticesIntersected += 1
            }

            previousφ = point.longitude * DegreesToRadians
            previousλ = point.latitude * DegreesToRadians
        }

        return (verticesIntersected & 1) != 0
    }

    /**
     Creates a polygon from an encoded path.

     - parameter encodedPath: The encoded path using Google's Encoded Polyline Algorithm Format.
     - parameter strokeWidth: The line width in points (default 1).
     - parameter strokeColor: The color of the stroke (default black).
     - parameter fillColor:   The color that will be used to fill the polygon (default blue).
     */
    public convenience init?(encodedPath: String, strokeWidth: CGFloat = 1.0,
                             strokeColor: UIColor = .blackColor(), fillColor: UIColor = .blueColor())
    {
        guard let coordinates = MapPath.decodePoints(encodedPath) else {
            return nil
        }

        self.init(coordinates: coordinates, strokeWidth: strokeWidth, strokeColor: strokeColor,
                  fillColor: fillColor)
    }

    /**
     Creates a polygon from an array of coordinates

     - parameter coordinates: An array of coordinates that will define the closed path.
     - parameter strokeWidth: The line width in points (default 1).
     - parameter strokeColor: The color of the stroke (default black).
     - parameter fillColor:   The color that will be used to fill the polygon (default blue).
     */
    public init(coordinates: [CLLocationCoordinate2D], strokeWidth: CGFloat = 1.0,
                strokeColor: UIColor = .blackColor(), fillColor: UIColor = .blueColor())
    {
        self.coordinates = coordinates
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.fillColor = fillColor
    }
}
