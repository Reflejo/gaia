import CoreLocation

public struct MapPlace {
    /// Location of the place or kLocationCoordinate2DInvalid if unknown
    public let coordinate: CLLocationCoordinate2D

    /// The name of the place. (e.g. AT&T Park)
    public let placeName: String?

    /// Street number and name.
    public let thoroughfare: String?

    /// Locality or city.
    public let locality: String?

    /// Region/State/Administrative area.
    public let administrativeArea: String?

    /// Postal/Zip code.
    public let postalCode: String?

    /// The country name.
    public let country: String?

    /// A string containing the best-effort formatted address.
    public let formattedAddress: String?
}
