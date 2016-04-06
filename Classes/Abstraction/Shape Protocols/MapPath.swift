import CoreLocation

/**
 MapPath encapsulates an immutable array of CLLocationCooordinate2D.
 */
public protocol MapPath {
    /// An array containing all the waypoints (i.e. GPS positions) on the path
    var coordinates: [CLLocationCoordinate2D] { get }

    /**
     Creates the path that contains all the given sets of points.

     - parameter points: The array of points that will be contained in the path.

     - returns: the newly created `MapPath` from the set of points.
     */
    static func withPoints(points: [CLLocationCoordinate2D]) -> MapPath

    /**
     Creates the path by extracting the points from the given encoded path.

     - parameter encodedPath: The encoded path using Google's Encoded Polyline Algorithm Format.

     - returns: the newly created `MapPath`.
     */
    static func fromEncodedPath(encodedPath: String) -> MapPath?
}
