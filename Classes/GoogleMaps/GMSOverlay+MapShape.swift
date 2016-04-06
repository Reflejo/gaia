import GoogleMaps

/**
 This protocol represents any Google Maps shape object that contains a path.
 */
public protocol GMSPathRepresentable {

    /// The path that describes this shape. The coordinates composing the path must be valid.
    var path: GMSPath? { get }
}

extension GMSPolygon: GMSPathRepresentable, MapPolygon {

    public static func fromEncodedPath(encodedPath: String) -> MapPolygon {
        return GMSPolygon(path: GMSPath(fromEncodedPath: encodedPath))
    }
}

extension GMSPolyline: GMSPathRepresentable, MapPolyline {

    public static func fromPath(path: MapPath) -> MapPolyline {
        guard let path = path as? GMSPath else {
            assertionFailure("A non-google maps path was given to a specialized Google Maps map")
            return GMSPolyline()
        }

        return GMSPolyline(path: path)
    }
}

extension GMSPath: MapPath {

    public var coordinates: [CLLocationCoordinate2D] {
        return (0 ..< self.count()).map { self.coordinateAtIndex($0) }
    }

    public static func withPoints(points: [CLLocationCoordinate2D]) -> MapPath {
        let path = GMSMutablePath()
        points.forEach { path.addLatitude($0.latitude, longitude: $0.longitude) }
        return path
    }

    public static func fromEncodedPath(encodedPath: String) -> MapPath? {
        return GMSPath(fromEncodedPath: encodedPath)
    }
}

extension GMSCircle: MapCircle {}

public extension MapShape where Self: GMSPathRepresentable {

    public var bounds: CoordinateBounds? {
        guard let path = self.path else {
            return nil
        }

        let bounds = GMSCoordinateBounds(path: path)
        return CoordinateBounds(coordinate: bounds.southWest, coordinate: bounds.northEast)
    }
}

extension GMSURLTileLayer: MapURLTileLayer {

    public static func withURLConstructor(constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?)
        -> MapURLTileLayer
    {
        return GMSURLTileLayer(URLConstructor: constructor)
    }
}
