import GoogleMaps

struct GoogleMapsUtils: MapUtilsProvider {

    static func polygonContainsPosition(position: CLLocationCoordinate2D, encodedPolygon: String) -> Bool {
        guard let path = GMSPath(fromEncodedPath: encodedPolygon) else {
            return false
        }

        return GMSGeometryContainsLocation(position, path, true)
    }

    static func interpolate(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, fraction: Double)
        -> CLLocationCoordinate2D
    {
        return GMSGeometryInterpolate(from, to, fraction)
    }

    static func heading(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection
    {
        return GMSGeometryHeading(from, to)
    }

    static func offset(from from: CLLocationCoordinate2D, distance: CLLocationDistance,
                            heading: CLLocationDegrees) -> CLLocationCoordinate2D
    {
        return GMSGeometryOffset(from, distance, heading)
    }
}
