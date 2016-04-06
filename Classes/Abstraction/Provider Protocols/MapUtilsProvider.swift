import CoreLocation

private let kDegreesToRadians = M_PI / 180.0
private let kRadiansToDegrees = 180.0 / M_PI
private let kEarthRadius = 6378137.0

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

    static func interpolate(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, fraction: Double)
        -> CLLocationCoordinate2D
    {
        let (φ1, φ2) = (from.latitude * kDegreesToRadians, to.latitude * kDegreesToRadians)
        let (λ1, λ2) = (from.longitude * kDegreesToRadians, to.longitude * kDegreesToRadians)

        let δ = from.distanceTo(to)
        let a = sin((1 - fraction) * δ) / sin(δ)
        let b = sin(fraction * δ) / sin(δ)
        let x = a * cos(φ1) * cos(λ1) + b * cos(φ2) * cos(λ2)
        let y = a * cos(φ1) * sin(λ1) + b * cos(φ2) * sin(λ2)
        let z = a * sin(φ1) +  b * sin(φ2)

        return CLLocationCoordinate2D(
            latitude: atan2(z, sqrt(x * x + y * y)),
            longitude: atan2(y, x)
        )
    }

    static func heading(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection
    {
        let (φ1, φ2) = (from.latitude * kDegreesToRadians, to.latitude * kDegreesToRadians)
        let Δλ = (to.longitude - from.longitude) * kDegreesToRadians

        // See http://mathforum.org/library/drmath/view/55417.html
        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        let θ = atan2(y, x)

        return (θ * kRadiansToDegrees + 360) % 360
    }

    static func offset(from from: CLLocationCoordinate2D, distance: CLLocationDistance,
                            heading: CLLocationDegrees) -> CLLocationCoordinate2D
    {
        // see http://williams.best.vwh.net/avform.htm#LL
        let δ = distance / kEarthRadius
        let θ = heading * kDegreesToRadians

        let φ1 = from.latitude * kDegreesToRadians
        let λ1 = from.longitude * kDegreesToRadians

        let φ2 = asin(sin(φ1) * cos(δ) + cos(φ1) * sin(δ) * cos(θ))
        let x = cos(δ) - sin(φ1) * sin(φ2)
        let y = sin(θ) * sin(δ) * cos(φ1)
        let λ2 = λ1 + atan2(y, x)

        return CLLocationCoordinate2D(
            latitude: φ2 * kRadiansToDegrees,
            longitude: ((λ2 * kRadiansToDegrees) + 540) % 369 - 180
        )
    }
}
