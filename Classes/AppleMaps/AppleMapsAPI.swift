import AddressBookUI
import Contacts
import MapKit

private let kNearbyRadiusMeters = 1000.0

struct AppleMapsAPI: MapAPIProvider {

    static var APIKey: String?

    private static let profilesMap: [MapTravelProfile: MKDirectionsTransportType] = [
        .Driving: .Automobile, .Walking: .Walking, .Cycling: .Automobile
    ]

    func reverseGeocode(coordinate coordinate: CLLocationCoordinate2D,
                                   completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemark, error in
            guard let placemarks = placemark else {
                let error: MapAPIError = error.map { .Error(error: $0.description) } ?? .UnknownError
                return completion(.Error(error))
            }

            let places = placemarks.map { MapPlace(coordinate: coordinate, placemark: $0) }
            completion(.Success(places))
        }
    }

    func searchNearbyPlaces(completion: MapAPIResponse<[MapPlace]> -> Void) {
        guard let coordinate = CLLocationManager().location?.coordinate else {
            let error = MapAPIError.Error(error: "Couldn't found user current location")
            return completion(.Error(error))
        }

        let northWest = MapUtils.offset(from: coordinate, distance: kNearbyRadiusMeters, heading: 315.0)
        let southEast = MapUtils.offset(from: coordinate, distance: kNearbyRadiusMeters, heading: 135.0)
        let bounds = CoordinateBounds(coordinate: northWest, coordinate: southEast)
        self.autocompleteQuery("", bounds: bounds, completion: completion)
    }

    func autocompleteQuery(query: String, bounds: CoordinateBounds?,
                           completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = query
        if let bounds = bounds {
            let span = MKCoordinateSpan(
                latitudeDelta: bounds.northEast.latitude - bounds.southWest.latitude,
                longitudeDelta: bounds.northEast.longitude - bounds.southWest.longitude
            )
            request.region = MKCoordinateRegion(center: bounds.center, span: span)
        }

        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, error in
            guard let mapItems = response?.mapItems else {
                let error = MapAPIError.Error(error: error?.description ?? "Unknown Error")
                return completion(.Error(error))
            }

            let places = mapItems.map { MapPlace(placeName: $0.name, placemark: $0.placemark) }
            completion(.Success(places))
        }
    }

    func directions(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                    completion: MapAPIResponse<([[CLLocationCoordinate2D]], ETAs: [NSTimeInterval])> -> Void)
    {
        if wayPoints.count < 2 {
            assertionFailure("WayPoints must contain at least 2 locations")
            return
        }

        var missingRoutes = wayPoints.count - 1
        for pointIndex in 1 ..< wayPoints.count {
            let source = MKPlacemark(coordinate: wayPoints[pointIndex - 1], addressDictionary: nil)
            let destination = MKPlacemark(coordinate: wayPoints[pointIndex], addressDictionary: nil)

            let request = MKDirectionsRequest()
            request.source = MKMapItem(placemark: source)
            request.destination = MKMapItem(placemark: destination)
            request.transportType = AppleMapsAPI.profilesMap[profile]!

            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler { response, error in
                missingRoutes -= 1
                guard missingRoutes >= 0, let response = response else {
                    let error = MapAPIError.Error(error: error?.description ?? "Unknown Error")
                    if missingRoutes >= 0 {
                        missingRoutes = -1
                        completion(.Error(error))
                    }

                    return
                }

                let times = response.routes.map { $0.expectedTravelTime }
                let legs = response.routes.map { route -> [CLLocationCoordinate2D] in
                    let pointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(route.polyline.pointCount)
                    route.polyline.getCoordinates(pointer, range: NSMakeRange(0, route.polyline.pointCount))

                    return (0 ..< route.polyline.pointCount).map { pointer[$0] }
                }

                if missingRoutes == 0 {
                    completion(.Success(legs, ETAs: times))
                }
            }
        }
    }

    func timeEstimated(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                                 completion: MapAPIResponse<[NSTimeInterval]> -> Void)
    {
        // Apple maps doesn't support time estimations; so we use the directions call for it.
        self.directions(wayPoints: wayPoints, profile: profile) { response in
            guard case .Success((let directions, let ETAs)) = response else {
                return
            }

            completion(.Success(ETAs))
        }
    }
}

// MARK: - MapPlace extensions

private extension MapPlace {

    init(coordinate: CLLocationCoordinate2D? = nil, placeName: String? = nil, placemark: CLPlacemark) {
        let thoroughfare = [placemark.subThoroughfare, placemark.thoroughfare]
            .flatMap { $0 }
            .joinWithSeparator(" ")

        let fullAddress: String?
        if #available(iOS 9.0, *) {
            let address = CNMutablePostalAddress()
            address.street = thoroughfare
            address.state = placemark.administrativeArea ?? ""
            address.city = placemark.locality ?? ""
            address.country = placemark.country ?? ""
            address.postalCode = placemark.postalCode ?? ""

            fullAddress = CNPostalAddressFormatter.stringFromPostalAddress(address, style: .MailingAddress)
        } else if let addressDictionary = placemark.addressDictionary {
            fullAddress = ABCreateStringWithAddressDictionary(addressDictionary, true)
        } else {
            fullAddress = nil
        }

        self.formattedAddress = fullAddress?.stringByReplacingOccurrencesOfString("\n", withString: ", ")
        self.coordinate = placemark.location?.coordinate ?? coordinate ?? kCLLocationCoordinate2DInvalid
        self.placeName = placeName ?? placemark.areasOfInterest?.first
        self.thoroughfare = thoroughfare.isEmpty ? nil : thoroughfare
        self.locality = placemark.locality
        self.administrativeArea = placemark.administrativeArea
        self.postalCode = placemark.postalCode
        self.country = placemark.country
    }
}
