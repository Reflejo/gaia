import CoreLocation

/**
 Classes conforming this protocol will contain the math to calculate map projections such as
 cartesian plane <=> earth coordinates and distances.
 */
public protocol MapProjection {

    /**
     Maps an Earth coordinate to a point coordinate in the map's view.

     - parameter coordinate: The earth coordinate (lat, lng).

     - returns: the point coordinate in the cartesian plane relative to the map view.
     */
    func pointForCoordinate(coordinate: CLLocationCoordinate2D) -> CGPoint

    /**
     Returns a CGFLoat representing how many points fit in one metter at the given coordinate (this will use
     the zoom on the map for when the projection was created).

     - parameter meters:     The distance in meters to convert
     - parameter coordinate: The base coordinate for the calculation

     - returns: the size in points for the given meters.
     */
    func pointsForMeters(meters: CLLocationDistance, atCoordinate coordinate: CLLocationCoordinate2D)
        -> CGFloat
}
