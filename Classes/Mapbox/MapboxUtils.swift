import Mapbox

struct MapboxUtils: MapUtilsProvider {

    static func polygonContainsPosition(position: CLLocationCoordinate2D, encodedPolygon: String) -> Bool {
        guard let coordinates = MapPath(encodedPath: encodedPolygon)?.coordinates else {
            return false
        }

        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>(coordinates)
        let polygon = MGLPolygon(coordinates: unsafeCoordinates, count: UInt(coordinates.count))

        return polygon.intersectsOverlayBounds(MGLCoordinateBounds(sw: position, ne: position))
    }
}
