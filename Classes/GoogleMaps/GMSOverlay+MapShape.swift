import GoogleMaps

/**
 This protocol represents any Google Maps shape object that contains a path.
 */
public protocol GMSPathRepresentable {

    /// The path that describes this shape. The coordinates composing the path must be valid.
    var path: GMSPath? { get }
}

extension GMSPolygon: GMSPathRepresentable, MapPolygon {

    public var strokeLineColor: UIColor {
        get { return self.strokeColor ?? .blackColor() }
        set { self.strokeColor = newValue }
    }

    public static func fromEncodedPath(encodedPath: String) -> MapPolygon? {
        guard let path = GMSPath(fromEncodedPath: encodedPath) else {
            return nil
        }

        return GMSPolygon(path: path)
    }
}

extension GMSPolyline: GMSPathRepresentable, MapPolyline {

    public var strokeLineColor: UIColor {
        get { return self.strokeColor ?? .blackColor() }
        set { self.strokeColor = newValue }
    }

    public static func fromPath(path: MapPath) -> MapPolyline {
        guard let path = path as? GMSPath else {
            assertionFailure("A non-google maps path was given to a specialized Google Maps map")
            return GMSPolyline()
        }

        return GMSPolyline(path: path)
    }
}

extension GMSCircle: MapCircle {

    public var strokeLineColor: UIColor {
        get { return self.strokeColor ?? .blackColor() }
        set { self.strokeColor = newValue }
    }
}

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
