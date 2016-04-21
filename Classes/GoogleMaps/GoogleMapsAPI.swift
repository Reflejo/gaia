import Alamofire
import GoogleMaps

private enum Route: URLStringConvertible {
    private static let baseURL = NSURL(string: "https://maps.googleapis.com/maps/api/")
    private static let APIVersion = "v4"

    case Directions
    case DistanceMatrix

    var path: String {
        switch self {
            case Directions:
                return "directions/json"

            case DistanceMatrix:
                return "distancematrix/json"
        }
    }

    private var URLString: String {
        let URL = NSURL(string: self.path, relativeToURL: Route.baseURL)!
        return URL.absoluteString
    }
}

struct GoogleMapsAPI: MapAPIProvider {

    static var APIKey: String?

    private static var profilesMap: [MapTravelProfile: String] = [
        .Driving: "driving", .Walking: "walking", .Cycling: "bicyling"
    ]

    func reverseGeocode(coordinate coordinate: CLLocationCoordinate2D,
                                   completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { response, error in
            guard let results = response?.results() else {
                let error: MapAPIError = error.map { .Error(error: $0.description) } ?? .UnknownError
                return completion(.Error(error))
            }

            let places = results.map { MapPlace(coordinate: coordinate, address: $0) }
            completion(.Success(places))
        }
    }

    func searchNearbyPlaces(completion: MapAPIResponse<[MapPlace]> -> Void) {
        GMSPlacesClient.sharedClient().currentPlaceWithCallback { placesList, error in
            guard let results = placesList?.likelihoods else {
                let error: MapAPIError = error.map { .Error(error: $0.description) } ?? .UnknownError
                return completion(.Error(error))
            }

            let places = results.map { MapPlace(place: $0.place) }
            completion(.Success(places))
        }
    }

    func autocompleteQuery(query: String, bounds: CoordinateBounds?,
                           completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        let bounds = bounds.map { GMSCoordinateBounds(coordinate: $0.northEast, coordinate: $0.southWest) }
        GMSPlacesClient
            .sharedClient()
            .autocompleteQuery(query, bounds: bounds, filter: nil) { response, error in
                guard let results = response else {
                    let error: MapAPIError = error.map { .Error(error: $0.description) } ?? .UnknownError
                    return completion(.Error(error))
                }

                let places = results.map(MapPlace.init)
                completion(.Success(places))
            }
    }

    func directions(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                    completion: MapAPIResponse<([[CLLocationCoordinate2D]], ETAs: [NSTimeInterval])> -> Void)
    {
        guard let first = wayPoints.first, last = wayPoints.last else {
            return
        }

        let wayPoints = wayPoints[1 ..< wayPoints.count - 1]
            .map { "\($0.latitude),\($0.longitude)" }
            .joinWithSeparator("|")

        let params: [String: AnyObject] = [
            "waypoints": wayPoints,
            "origin": "\(first.latitude),\(first.longitude)",
            "destination": "\(last.latitude),\(last.longitude)",
            "mode": GoogleMapsAPI.profilesMap[profile]!,
            "sensor": "true"
        ]

        Alamofire
            .request(.GET, Route.Directions, parameters: params)
            .responseJSON { response in
                let parsedResponse = self.parseResponse(response)
                guard case .Success(let json) = parsedResponse else {
                    return completion(.Error(parsedResponse.error ?? .UnknownError))
                }

                let (legs, times) = self.parseDirectionsResponse(json)
                completion(.Success(legs, ETAs: times))
            }
    }

    func timeEstimated(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                                 completion: MapAPIResponse<[NSTimeInterval]> -> Void)
    {
        if wayPoints.count < 2 {
            assertionFailure("You should call timeEstimated with at least two locations")
            return
        }

        let origins = wayPoints[0 ..< wayPoints.count - 1]
        let destinations = wayPoints[1 ..< wayPoints.count]
        let params: [String: AnyObject] = [
            "mode": GoogleMapsAPI.profilesMap[profile]!,
            "origins": origins.map { "\($0.latitude),\($0.longitude)" }.joinWithSeparator("|"),
            "destinations": destinations.map { "\($0.latitude),\($0.longitude)" }.joinWithSeparator("|"),
            "sensor": "true"
        ]

        Alamofire
            .request(.GET, Route.DistanceMatrix, parameters: params)
            .responseJSON { response in
                let parsedResponse = self.parseResponse(response)
                guard case .Success(let json) = parsedResponse,
                    let rows = json["rows"] as? [NSDictionary] else
                {
                    return completion(.Error(parsedResponse.error ?? .UnknownError))
                }

                var times: [NSTimeInterval] = []
                let timeElements = rows.map { $0["elements"] as? [NSDictionary] }
                for legIndex in 0 ..< origins.count {
                    guard let legTimes = timeElements[legIndex] where legTimes.count == origins.count else {
                        return completion(.Error(.ParsingError))
                    }

                    let legTime = legTimes[legIndex].valueForKeyPath("duration.value") as? NSTimeInterval
                    times.append(legTime ?? -1.0)
                }

                completion(.Success(times))
            }
    }

    // MARK: - Private helpers

    private func parseResponse(response: Response<AnyObject, NSError>) -> MapAPIResponse<NSDictionary> {
        guard case .Success(let data) = response.result else {
            let error = response.result.error.map { MapAPIError.Error(error: $0.description) }
            return .Error(error ?? .UnknownError)
        }

        switch response.response?.statusCode ?? 0 {
            case 429:
                return .Error(.QuotaExceeded)

            case 200 ..< 300 where data is NSDictionary:
                return .Success(data as! NSDictionary)

            default:
                return .Error(.UnknownError)
        }
    }

    private func parseDirectionsResponse(response: NSDictionary)
        -> (legs: [[CLLocationCoordinate2D]], times: [NSTimeInterval])
    {
        let routes = response["routes"] as? [NSDictionary]
        let legsInfo = routes?.first?["legs"] as? [NSDictionary] ?? []

        let times = legsInfo.map { $0["duration"]?["value"] as? NSTimeInterval ?? -1.0 }
        let legs = legsInfo.map { leg -> [CLLocationCoordinate2D] in
            let steps = leg["steps"] as? [NSDictionary] ?? []

            return steps.flatMap { (step: NSDictionary) -> [CLLocationCoordinate2D] in
                let polyline = step["polyline"] as? NSDictionary
                let encodedPoints = polyline?["points"] as? String ?? ""
                return MapPath.decodePoints(encodedPoints) ?? []
            }
        }
        return (legs, times)
    }
}

// MARK: - Places private extensions

private extension MapPlace {

    init(place: GMSPlace) {
        var componentsMap: [String: String] = [:]
        for component in (place.addressComponents ?? []) {
            componentsMap[component.type] = component.name
        }

        self.formattedAddress = place.formattedAddress
        self.coordinate = place.coordinate
        self.placeName = place.name
        self.thoroughfare = nil
        self.locality = componentsMap["locality"]
        self.administrativeArea = componentsMap["administrative_area_level_1"]
        self.postalCode = componentsMap["postal_code"]
        self.country = componentsMap["country"]
    }

    init(coordinate: CLLocationCoordinate2D, address: GMSAddress) {
        self.coordinate = CLLocationCoordinate2DIsValid(address.coordinate) ? address.coordinate : coordinate
        self.placeName = nil
        self.thoroughfare = address.thoroughfare
        self.locality = address.locality
        self.administrativeArea = address.administrativeArea
        self.postalCode = address.postalCode
        self.country = address.country
        self.formattedAddress = address.lines?.joinWithSeparator(", ")
    }

    init(prediction: GMSAutocompletePrediction) {
        self.formattedAddress = prediction.attributedFullText.string
        self.placeName = prediction.attributedPrimaryText.string
        self.coordinate = kCLLocationCoordinate2DInvalid
        self.thoroughfare = nil
        self.locality = nil
        self.administrativeArea = nil
        self.postalCode = nil
        self.country = nil
    }
}
