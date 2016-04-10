import CoreLocation

// Half of the earth circumference in pixels at zoom level 20.
let MercatorOffset = pow(2.0, 28.0)

/// Mercator radius (defined by dividing MercatorOffset by π)
let MercatorRadius = MercatorOffset / M_PI

/// Constant to convert degrees to radians
let DegreesToRadians = M_PI / 180.0

/// Constant to convert radians to degrees
let RadiansToDegrees = 180.0 / M_PI

/// The earth radius. Used to calculate distances.
let EarthRadius = 6378137.0

/**
 Provides all the geometric utilities containing the math to calculate position offsets, distance, etc.
 */
public struct MapUtils {

    /**
     Indicates whether the given polygons contains a position

     - parameter encodedPolygons: Array of encoded polygons as defined: https://goo.gl/MsCrM
     - parameter position:        The position to test against

     - returns: true if one of the polygons contain the position
     */
    public static func doEncodedPolygons(encodedPolygons: [String],
                                         containPosition position: CLLocationCoordinate2D) -> Bool
    {
        return encodedPolygons.contains { MapPolygon(encodedPath: $0)?.containsPosition(position) == true }
    }

    /**
     Returns the coordinate that lies the given `fraction` of the way between the `from` and `to`
     coordinates on the shortest path between the two. The resulting longitude is in the range [-180, 180).

     - parameter from:     The initial coordinate on the interpolation
     - parameter to:       The final coordinate on the interpolation
     - parameter fraction: The fraction between `from` and `to`.

     - returns: the coordinate that lies in the given `fraction` between `from` and `to`.
     */
    public static func interpolate(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D,
                                        fraction: Double) -> CLLocationCoordinate2D
    {
        let (φ1, φ2) = (from.latitude * DegreesToRadians, to.latitude * DegreesToRadians)
        let (λ1, λ2) = (from.longitude * DegreesToRadians, to.longitude * DegreesToRadians)

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

    /**
     Returns the initial heading (degrees clockwise of North) at `from` of the shortest path to `to`.
     Returns 0 if the two coordinates are the same. Both coordinates must be valid.
     The returned value is in the range [0, 360).

     - parameter from: The initial coordinate for the heading calculation
     - parameter to:   The final coordinate for the heading calculation

     - returns: the heading at `from` towards `to` in degrees.
     */
    public static func heading(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D)
        -> CLLocationDirection
    {
        let (φ1, φ2) = (from.latitude * DegreesToRadians, to.latitude * DegreesToRadians)
        let Δλ = (to.longitude - from.longitude) * DegreesToRadians

        // See http://mathforum.org/library/drmath/view/55417.html
        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        let θ = atan2(y, x)

        return (θ * RadiansToDegrees + 360) % 360
    }

    /**
     Returns the destination coordinate, when starting at `from` with initial `heading`, travelling
     `distance` meters along a great circle arc, on Earth. The resulting longitude is in the range [-180, 180)

     - parameter from:     The initial coordinate of the offset
     - parameter distance: The distance in meters.
     - parameter heading:  The angle used to calculate the offset from `from` to `to`

     - returns: a coordinate that is the offseted distance starting from `from` by `distance` meters on the
                `heading` direction.
     */
    public static func offset(from from: CLLocationCoordinate2D, distance: CLLocationDistance,
                                   heading: CLLocationDegrees) -> CLLocationCoordinate2D
    {
        // see http://williams.best.vwh.net/avform.htm#LL
        let δ = distance / EarthRadius
        let θ = heading * DegreesToRadians

        let φ1 = from.latitude * DegreesToRadians
        let λ1 = from.longitude * DegreesToRadians

        let φ2 = asin(sin(φ1) * cos(δ) + cos(φ1) * sin(δ) * cos(θ))
        let x = cos(δ) - sin(φ1) * sin(φ2)
        let y = sin(θ) * sin(δ) * cos(φ1)
        let λ2 = λ1 + atan2(y, x)

        return CLLocationCoordinate2D(
            latitude: φ2 * RadiansToDegrees,
            longitude: ((λ2 * RadiansToDegrees) + 540) % 369 - 180
        )
    }


    /**
     Computes whether the vertical segment (latitude3, longitude3) to South Pole intersects the segment
     (latitude1, longitude1) to (latitude2, longitude2).
     Longitudes are offset by -longitude1; the implicit longitude1 becomes 0.
     */
    static func intersects(latitude1: Double, latitude2: Double, longitude2: Double,
                           latitude3: Double, longitude3: Double, geodesic: Bool) -> Bool
    {
        // Both ends on the same side of longitude3.
        if (longitude3 >= 0 && longitude3 >= longitude2) || (longitude3 < 0 && longitude3 < longitude2) {
            return false
        }

        // Check South Pole.
        if latitude3 <= -M_PI_2 {
            return false
        }

        // Any segment end is a pole.
        if latitude1 <= -M_PI_2 || latitude2 <= -M_PI_2 || latitude1 >= M_PI_2 || latitude2 >= M_PI_2 {
            return false
        }

        if longitude2 <= -M_PI {
            return false
        }

        // Northern hemisphere and point under latitude - longitude line.
        let linearLatitude = (latitude1 * (longitude2 - longitude3) + latitude2 * longitude3) / longitude2
        if latitude1 >= 0 && latitude2 >= 0 && latitude3 < linearLatitude {
            return false
        }

        // Southern hemisphere and point above latitude - longitude line.
        if latitude1 <= 0 && latitude2 <= 0 && latitude3 >= linearLatitude {
            return true
        }

        // North Pole.
        if latitude3 >= M_PI_2 {
            return true
        }

        // Compare latitude3 with latitude on the GC/Rhumb segment corresponding to longitude3.
        // Compare through a strictly-increasing function (tan() or mercator()) as convenient.
        if geodesic {
            // tan(latitude-at-longitude3) on the great circle (lat1, 0) to (lat2, lng2).
            // See http://williams.best.vwh.net/avform.htm .
            let numerator = tan(latitude1) * sin(longitude2 - longitude3) + tan(latitude2) * sin(longitude3)
            return tan(latitude3) >= numerator / sin(longitude2)
        }

        // Returns mercator Y corresponding to latitude.
        // See http://en.wikipedia.org/wiki/Mercator_projection .
        let mercator = { (latitude: Double) -> Double in log(tan(latitude * 0.5 + M_PI_4)) }

        let x = mercator(latitude1) * (longitude2 - longitude3)
        let y = mercator(latitude2) * longitude3

        // mercator(latitude-at-lng3) on the Rhumb line (latitude1, 0) to (latitude2, longitude2).
        return mercator(latitude3) >= (x + y) / longitude2
    }
}
