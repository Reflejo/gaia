import CoreLocation

private let kMinDistanceMeters = 5.0 // Distance in meters for equality
private let kDegreesToRadians = M_PI / 180.0
private let kEarthRadius = 6378137.0

extension CLLocationCoordinate2D {

    /**
     Returns the distance (in meters) from the receiver's coordinate to the specified coordinate.

     - parameter coordinate: The other coordinate

     - returns: The distance (in meters) between the two coordinates.
     */
    func distanceTo(coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        // The default `distanceFromLocation` behavior will return 0 if any of the locations is invalid.
        if !CLLocationCoordinate2DIsValid(coordinate) || !CLLocationCoordinate2DIsValid(self) {
            return CLLocationDistanceMax
        }

        let (λ1, λ2) = (self.longitude * kDegreesToRadians, coordinate.longitude * kDegreesToRadians)
        let (φ1, φ2) = (self.latitude * kDegreesToRadians, coordinate.latitude * kDegreesToRadians)
        let x = (λ2 - λ1) * cos((φ1 + φ2) / 2.0)
        let y = φ2 - φ1

        return sqrt(x * x + y * y) * kEarthRadius
    }
}

/**
 Equatable definition for CLLocationCoordinate2D, this checks that the coordinates are "very close".

 - parameter lhs: A CLLocationCoordinate2D to compare
 - parameter rhs: A CLLocationCoordinate2D to compare
 */
func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.distanceTo(rhs) <= kMinDistanceMeters
}

/**
 Equatable definition for CLLocationCoordinate2D, this checks that the coordinates are "far away".

 - parameter lhs: A CLLocationCoordinate2D to compare
 - parameter rhs: A CLLocationCoordinate2D to compare
 */
func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.distanceTo(rhs) > kMinDistanceMeters
}
