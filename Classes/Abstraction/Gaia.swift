import CoreLocation

/**
 This struct encapsulates a provider. SDKProviders will extend this struct as:

 ```
 extension MapProviderIdentifier {
    public let GoogleMaps = MapProviderIdentifier(GoogleMapsView)
 }
 ```

 so we don't need to make providers public and consumers can use this identifier instead (`.GoogleMaps`).
 */
public struct MapProviderIdentifier {

    /// The internal SDK provider.
    let provider: MapSDKProvider.Type

    /**
     Creates a `MapProviderIdentifier` by wrapping the `SDKProvider.Type` internally.

     - parameter provider: The Type of the concrete MapSDKProvider conformer.
     */
    init(_ provider: MapSDKProvider.Type) {
        self.provider = provider
    }
}

public struct Gaia {

    /// The SDK provider that is selected. Note that you have to set this before creating the MapView as
    /// every method in `Gaia` will use this as the `MapProvider`. Changing this with an existing `MapView`
    /// is not supported and will result on an undefined behavior.
    public static var SDK: MapProviderIdentifier?

    /// Helper to access the `Types` for the set SDK provider.
    static var ProviderTypes: MapProviderTypes {
        assert(Gaia.SDK == nil, "You need to specify a provider before using Gaia.")
        return Gaia.SDK!.provider.types
    }

    /// The specialized class with the geometric utils for the set SDK provider.
    public static var Utils: MapUtilsProvider.Type {
        return ProviderTypes.UtilsType
    }

    /**
     Creates a concrete instance conforming to `MapMarker`. Note that the instance type will depend on
     the set SDK Provider.

     - parameter position: The earth coordinate.

     - returns: the newly created instance conforming to `MapMarker`.
     */
    public static func createMarker(atPosition position: CLLocationCoordinate2D) -> MapMarker {
        return ProviderTypes.MarkerType.init(position: position)
    }

    /**
     Creates a concrete instance conforming to `MapURLTileLayer`. Note that the instance type will depend on
     the set SDK Provider.

     - parameter constructor: A closure that, given (x, y, zoom) will return a valid URL to request.

     - returns: the newly created instance conforming to `MapURLTileLayer`.
     */
    public static func createURLTileOverlay(constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?)
        -> MapURLTileLayer
    {
        return ProviderTypes.MapURLTileLayerType.withURLConstructor(constructor)
    }

    /**
     Creates a concrete instance conforming to `MapCircle`. Note that the instance type will depend on the
     set SDK Provider.

     - parameter position: The position on earth of circle center.
     - parameter radius:   The radius of the circle in meters.

     - returns: the newly created instance conforming to `MapCircle`.
     */
    public static func createCircle(position position: CLLocationCoordinate2D, radius: CLLocationDistance)
        -> MapCircle
    {
        return ProviderTypes.CircleType.init(position: position, radius: radius)
    }

    /**
     Creates a concrete instance conforming to `MapPolyline`. Note that the instance type will depend on the
     set SDK Provider.

     - parameter path:        The `MapPath` from where the polyline will be drawn.
     - parameter strokeColor: The UIColor used to render the polyline.
     - parameter strokeWidth: The width of the line in screen points.

     - returns: the newly created instance conforming to `MapPolyline`.
     */
    public static func createPolyline(withPath path: MapPath, strokeColor: UIColor = .blueColor(),
                                               strokeWidth: CGFloat = 1) -> MapPolyline
    {
        var polyline = ProviderTypes.PolylineType.fromPath(path)
        polyline.strokeColor = strokeColor
        polyline.strokeWidth = strokeWidth
        return polyline
    }

    /**
     Creates a concrete instance conforming to `MapPolygon`. Note that the instance type will depend on the
     set SDK Provider.

     - parameter encodedPath: The path represented using Google's Encoded Polyline Algorithm Format.

     - returns: the newly created instance conforming to `MapPolygon`.
     */
    public static func createPolygon(fromEncodedPath encodedPath: String) -> MapPolygon {
        return ProviderTypes.PolygonType.fromEncodedPath(encodedPath)
    }

    /**
     Creates a concrete instance conforming to `MapPath`. Note that the instance type will depend on the
     set SDK Provider.

     - parameter points: The array of points that will be contained in the path.

     - returns: the newly created instance conforming to `MapPath`.
     */
    public static func createPath(withPoints points: [CLLocationCoordinate2D]) -> MapPath {
        return ProviderTypes.PathType.withPoints(points)
    }

    /**
     Creates a concrete instance conforming to `MapPath`. Note that the instance type will depend on the
     set SDK Provider.

     - parameter encodedPath: The path represented using Google's Encoded Polyline Algorithm Format.

     - returns: the newly created instance conforming to `MapPath`.
     */
    public static func createPath(fromEncodedPath encodedPath: String) -> MapPath? {
        return ProviderTypes.PathType.fromEncodedPath(encodedPath)
    }

    /**
     Creates a concrete instance conforming to the protocol defined as the result value of the closure. You
     can use the closure to set any needed property. Note that you first need to use `registerType`, with all
     the concrete Types for the supported Map Providers.

     Usage example:
     ```
     Gaia.registerType(GoogleYourMarker.self, for: YourMarkerProtocol.self, andProvider: .GoogleMaps)
     let marker = Gaia.createCustomShape { (Class: YourMarkerProtocol.Type) in
        Class.init(whatever: property)
     }
     ```

     - parameter create: A closure that will create and return the concrete class. The argument of the closure
                         will be the concrete class type (for example: GMSMarker.Type); that matched the
                         given type (which was previously registerd on `Gaia.registerType`.

     - returns: the newly created custom type or nil if no concrete type is found.
     */
    public static func createCustomShape<T, U>(@noescape create: T -> U?) -> U? {
        guard let Type = ProviderTypes.customTypes[ObjectIdentifier(U)] as? T else {
            return nil
        }

        return create(Type)
    }

    /**
     Registers a new concrete type for a given protocol. You should provider one for each map provider. See
     `Gaia.createCustomShape` for an usage example.

     - parameter type:         The concrete Type that should be used when creating this custom shape.
     - parameter protocolType: The protocol that the concrete type conforms (note that the protocol should
                               be the same regardless of the provider).
     - parameter providerID:   The Provider where this type will be associated (e.g. `.GoogleMaps`)
     */
    public static func registerType<T>(type: T.Type, `for` protocolType: Any.Type,
                                    andProvider providerID: MapProviderIdentifier)
    {
        let provider = providerID.provider
        provider.types.customTypes[ObjectIdentifier(protocolType)] = type
    }

    /**
     Provides your API key to the Map Provider SDK. This needs to be called once, before any operation.

     - parameter key:        The Provider SDK key.
     - parameter providerID: The Provider where the key will be set on. (e.g. `GoogleMaps`)
     */
    public static func provideAPIKey(key: String, forProvider providerID: MapProviderIdentifier) {
        let provider = providerID.provider
        provider.provideAPIKey(key)
    }
}
