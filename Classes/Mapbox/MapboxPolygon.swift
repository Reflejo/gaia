import Mapbox

final class MapboxPolygon: MGLPolygon, MapPolygon {
    var fillColor: UIColor? = .magentaColor()
    var strokeWidth: CGFloat = 1.0
    var strokeLineColor = UIColor.blackColor()
    var zIndex: Int32 = 1

    static func fromEncodedPath(encodedPath: String) -> MapPolygon? {
        guard let coordinates = MapPath(encodedPath: encodedPath)?.coordinates else {
            return nil
        }

        let unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>(coordinates)
        return MapboxPolygon(coordinates: unsafeCoordinates, count: UInt(coordinates.count))
    }
}