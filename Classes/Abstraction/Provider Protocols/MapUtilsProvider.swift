import CoreLocation

/**
 Provides all the geometric utilities containing the math to calculate position offsets, distance, etc.
 */
public protocol MapUtilsProvider {

    /**
     Returns true if position is contained within polygon.

     - parameter position:       The point that may be contained within the specified polygon.
     - parameter encodedPolygon: Area that may contain the position, encoded as a polyline string.
     */
    static func polygonContainsPosition(position: CLLocationCoordinate2D, encodedPolygon: String) -> Bool

    /**
     Returns the coordinate that lies the given `fraction` of the way between the `from` and `to`
     coordinates on the shortest path between the two. The resulting longitude is in the range [-180, 180).

     - parameter from:     The initial coordinate on the interpolation
     - parameter to:       The final coordinate on the interpolation
     - parameter fraction: The fraction between `from` and `to`.

     - returns: the coordinate that lies in the given `fraction` between `from` and `to`.
     */
    static func interpolate(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, fraction: Double)
        -> CLLocationCoordinate2D

    /**
     Returns the initial heading (degrees clockwise of North) at `from` of the shortest path to |to|.
     Returns 0 if the two coordinates are the same. Both coordinates must be valid.
     The returned value is in the range [0, 360).

     - parameter from: The initial coordinate for the heading calculation
     - parameter to:   The final coordinate for the heading calculation

     - returns: the heading at `from` towards `to` in degrees.
     */
    static func heading(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection

    /**
     Returns the destination coordinate, when starting at `from` with initial `heading`, travelling
     `distance` meters along a great circle arc, on Earth. The resulting longitude is in the range [-180, 180)

     - parameter from:     The initial coordinate of the offset
     - parameter distance: The distance in meters.
     - parameter heading:  The angle used to calculate the offset from `from` to `to`

     - returns: a coordinate that is the offseted distance starting from `from` by `distance` meters on the
                `heading` direction.
     */
    static func offset(from from: CLLocationCoordinate2D, distance: CLLocationDistance,
                                   heading: CLLocationDegrees) -> CLLocationCoordinate2D

    /**
     Returns the destination coordinate, when starting at `from` with initial `heading`, travelling
     `distance` meters along a great circle arc, on Earth. The resulting longitude is in the range [-180, 180)

     - parameter from:     The initial coordinate of the offset
     - parameter distance: The distance in meters.
     - parameter heading:  The angle used to calculate the offset from `from` to `to`

     - returns: a coordinate that is the offseted distance starting from `from` by `distance` meters on the
                `heading` direction.
     */
    static func boundsEdges(fromCoordinates coordinates: [CLLocationCoordinate2D])
        -> (northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D)
}

extension MapUtilsProvider {

    /**
     Indicates whether the given polygons contains a position

     - parameter encodedPolygons: Array of encoded polygons as defined: https://goo.gl/MsCrM
     - parameter position:        The position to test against

     - returns: true if one of the polygons contain the position
     */
    public static func doEncodedPolygons(encodedPolygons: [String],
                                         containPosition position: CLLocationCoordinate2D) -> Bool
    {
        return encodedPolygons.contains { self.polygonContainsPosition(position, encodedPolygon: $0) }
    }
}
