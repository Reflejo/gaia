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
public struct MapProviderIdentifier: Equatable {

    private static var providersByName: [String: MapProviderIdentifier] = [:]

    /// The internal SDK provider.
    let provider: MapSDKProvider.Type

    /// The internal SDK provider.
    let APIProvider: MapAPIProvider.Type

    /// The internal SDK name.
    let name: String

    /**
     Returns the map provider named after the given name.

     - parameter name: The name identifying the provider.

     - returns: a `MapProviderIdentifier` if the name is found, otherwise nil.
     */
    static func withName(name: String) -> MapProviderIdentifier? {
        return self.providersByName[name]
    }

    /**
     Creates a `MapProviderIdentifier` by wrapping the `SDKProvider.Type` internally.

     - parameter provider: The Type of the concrete MapSDKProvider conformer.
     - parameter api:      The Type of the concrete MapAPIProvider conformer.
     - parameter name:     A human friendly description of the provider.
     */
    init(_ provider: MapSDKProvider.Type, api: MapAPIProvider.Type, name: String) {
        self.provider = provider
        self.name = name
        self.APIProvider = api
    }
}

public struct Gaia {

    /**
     Provides your API key to the Map Provider SDK. This needs to be called once, before any operation.

     - parameter key:        The Provider SDK key.
     - parameter providerID: The Provider where the key will be set on. (e.g. `GoogleMaps`)
     */
    public static func registerProvider(providerID: MapProviderIdentifier, APIKey: String = "") {
        MapProviderIdentifier.providersByName[providerID.name] = providerID

        let provider = providerID.provider
        provider.provideAPIKey(APIKey)
        providerID.APIProvider.APIKey = APIKey
    }
}

/**
 Compares two map provider identifier by checking the underlying provider.
 */
public func == (lhs: MapProviderIdentifier, rhs: MapProviderIdentifier) -> Bool {
    return lhs.provider == rhs.provider
}
