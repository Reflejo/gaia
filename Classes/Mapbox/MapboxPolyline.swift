import Mapbox

final class MapboxPolyline: MGLPolyline, MapPolyline, MapOverlay {
    var strokeWidth: CGFloat = 1.0
    var strokeLineColor = UIColor.blackColor()
    var zIndex: Int32 = 1

    static func fromPath(path: MapPath) -> MapPolyline {
        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>(path.coordinates)
        return MapboxPolyline(coordinates: unsafeCoordinates, count: UInt(path.coordinates.count))
    }
}
