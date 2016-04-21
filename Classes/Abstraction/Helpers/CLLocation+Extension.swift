import CoreLocation

private let kMinDistanceMeters = 5.0 // Distance in meters for equality
private let kScale = 100000.0  // 5 digits after decimal point

extension CLLocationCoordinate2D: Hashable {}
public extension CLLocationCoordinate2D {

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

        let (λ1, λ2) = (self.longitude * DegreesToRadians, coordinate.longitude * DegreesToRadians)
        let (φ1, φ2) = (self.latitude * DegreesToRadians, coordinate.latitude * DegreesToRadians)
        let x = (λ2 - λ1) * cos((φ1 + φ2) / 2.0)
        let y = φ2 - φ1

        return sqrt(x * x + y * y) * EarthRadius
    }

    public var hashValue: Int {
        let latitude = Int(round(self.latitude * kScale))
        let longitude = Int(round(self.longitude * kScale))
        return latitude ^ ((longitude << 16) | (longitude >> 16))
    }
}

/**
 Equatable definition for CLLocationCoordinate2D, this checks that the coordinates are
 the same with the scale of 5 decimal.

 - parameter lhs: A CLLocationCoordinate2D to compare
 - parameter rhs: A CLLocationCoordinate2D to compare
 */
public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    let lhsInvalid = !CLLocationCoordinate2DIsValid(lhs) || isnan(lhs.latitude) || isnan(lhs.longitude)
    let rhsInvalid = !CLLocationCoordinate2DIsValid(rhs) || isnan(rhs.latitude) || isnan(rhs.longitude)
    if lhsInvalid || rhsInvalid {
        return lhsInvalid == rhsInvalid
    }

    return Int(round(lhs.latitude * kScale)) == Int(round(rhs.latitude * kScale)) &&
        Int(round(lhs.longitude * kScale)) == Int(round(rhs.longitude * kScale))
}
