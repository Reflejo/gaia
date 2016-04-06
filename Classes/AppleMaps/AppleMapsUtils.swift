import MapKit

struct AppleMapsUtils: MapUtilsProvider {

    static func polygonContainsPosition(position: CLLocationCoordinate2D, encodedPolygon: String) -> Bool {
        guard let coordinates = MapPath(encodedPath: encodedPolygon)?.coordinates else {
            return false
        }

        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>(coordinates)
        let polygon = MKPolygon(coordinates: unsafeCoordinates, count: coordinates.count)

        let rect = MKMapRect(origin: MKMapPointForCoordinate(position), size: MKMapSize(width: 1, height: 1))
        return polygon.intersectsMapRect(rect)
   }
}