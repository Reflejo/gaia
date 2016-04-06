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

    static func boundsEdges(fromCoordinates coordinates: [CLLocationCoordinate2D])
        -> (northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D)
    {
        let bounds = coordinates.reduce(GMSCoordinateBounds()) { $0.includingCoordinate($1) }
        return (bounds.northEast, bounds.southWest)
    }
}
