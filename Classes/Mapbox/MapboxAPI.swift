import Alamofire
import CoreLocation

private enum Route: URLStringConvertible {
    private static let baseURL = NSURL(string: "https://api.mapbox.com/")

    case Directions(profile: String, waypoints: String)
    case DurationMatrix(profile: String)
    case Geocoding(String)

    private var path: String {
        switch self {
            case Directions(let profile, let waypoints):
                return "/v4/directions/mapbox.\(profile)/\(waypoints).json"

            case DurationMatrix(let profile):
                return "/distances/v1/mapbox/\(profile)"

            case Geocoding(let query):
                let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
                allowed.addCharactersInString("-._~/?,")

                let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(allowed)
                return "/geocoding/v5/mapbox.places/\(encodedQuery ?? "").json"
        }
    }

    private var URLString: String {
        let URL = NSURL(string: self.path, relativeToURL: Route.baseURL)!
        return URL.absoluteString
    }
}

struct MapboxAPI: MapAPIProvider {

    static var APIKey: String?

    private static let profilesMap: [MapTravelProfile: String] = [
        .Driving: "driving", .Walking: "walking", .Cycling: "cycling"
    ]

    func reverseGeocode(coordinate coordinate: CLLocationCoordinate2D,
                                   completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        let params: [String: AnyObject] = [
            "access_token": MapboxAPI.APIKey ?? "",
            "autocomplete": false
        ]

        let query = "\(coordinate.longitude),\(coordinate.latitude)"
        Alamofire
            .request(.GET, Route.Geocoding(query), parameters: params)
            .responseJSON { response in
                let parsedResponse = self.parseResponse(response)
                guard case .Success(let json) = parsedResponse else {
                    return completion(.Error(parsedResponse.error ?? .UnknownError))
                }

                guard let features = json["features"] as? [NSDictionary] else {
                    return completion(.Error(MapAPIError.ParsingError))
                }

                let places = features.map { MapPlace(coordinate: coordinate, feature: $0) }
                completion(.Success(places))
            }
    }

    func searchNearbyPlaces(completion: MapAPIResponse<[MapPlace]> -> Void) {
        assertionFailure("Mapbox doesn't support nearby search without a query. :(")
    }

    func autocompleteQuery(query: String, bounds: CoordinateBounds?,
                           completion: MapAPIResponse<[MapPlace]> -> Void)
    {
        var params: [String: AnyObject] = [
            "access_token": MapboxAPI.APIKey ?? "",
            "types": "poi,place,address,neighborhood",
            "autocomplete": "true"
        ]
        params["proximity"] = bounds.map { "\($0.center.longitude),\($0.center.latitude)" }

        Alamofire
            .request(.GET, Route.Geocoding(query), parameters: params)
            .responseJSON { response in
                let parsedResponse = self.parseResponse(response)
                guard case .Success(let json) = parsedResponse else {
                    return completion(.Error(parsedResponse.error ?? .UnknownError))
                }

                guard let features = json["features"] as? [NSDictionary] else {
                    return completion(.Error(MapAPIError.ParsingError))
                }

                let places = features.map { MapPlace(feature: $0) }
                completion(.Success(places))
            }
    }

    func directions(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                    completion: MapAPIResponse<([[CLLocationCoordinate2D]], ETAs: [NSTimeInterval])> -> Void)
    {
        let stops = wayPoints.map { "\($0.longitude),\($0.latitude)" }.joinWithSeparator(";")
        let params = [
            "geometry": "polyline",
            "access_token": MapboxAPI.APIKey ?? "",
            "steps": "true"
        ]

        let route = Route.Directions(profile: MapboxAPI.profilesMap[profile]!, waypoints: stops)
        Alamofire
            .request(.GET, route, parameters: params)
            .responseJSON { response in
                let parsedResponse = self.parseResponse(response)
                guard case .Success(let json) = parsedResponse else {
                    return completion(.Error(parsedResponse.error ?? .UnknownError))
                }

                guard let routes = json["routes"] as? [NSDictionary] else {
                    return completion(.Error(MapAPIError.ParsingError))
                }

                let times = routes.flatMap { ($0["duration"] as? NSTimeInterval) ?? -1.0 }
                let legs = routes.flatMap { routeInfo -> [CLLocationCoordinate2D]? in
                    let encodedPath = routeInfo["geometry"] as? String
                    return MapPath.decodePoints(encodedPath ?? "", precision: 1e6)
                }

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

        let params: [String: AnyObject] = [
            "coordinates": wayPoints.map { [$0.longitude, $0.latitude] },
        ]

        let route = Route.DurationMatrix(profile: MapboxAPI.profilesMap[profile]!)
        let components = NSURLComponents(string: route.URLString)!
        components.queryItems = [NSURLQueryItem(name: "access_token", value: MapboxAPI.APIKey ?? "")]
        Alamofire
            .request(.POST, components, parameters: params, encoding: .JSON)
            .responseJSON { response in
                let parsed = self.parseResponse(response)
                guard case .Success(let json) = parsed, let durations = json["durations"] as? NSArray
                    where durations.count == wayPoints.count else
                {
                    return completion(.Error(parsed.error ?? .UnknownError))
                }

                // The result is in the form of a matrix, if [A, B, C] is given, the result will be:
                // durations = [
                //   [ A -> A, A -> B, A -> C],
                //   [ B -> A, B -> B, B -> C],
                //   [ C -> A, C -> B, C -> C],
                // ]
                // So we always want the diagonal of the matrix displaced by 1 to the left.
                let times = (0 ..< wayPoints.count - 1).map { index -> NSTimeInterval in
                    if durations[index + 1].count < wayPoints.count {
                        return -1.0
                    }

                    return durations[index][index + 1] as? NSTimeInterval ?? -1.0
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
}

// MARK: - MapPlace extensions

private extension MapPlace {

    init(coordinate: CLLocationCoordinate2D? = nil, feature: NSDictionary) {
        let placeID = feature["id"] as? String
        let center = feature["center"] as? [CLLocationDegrees]
        let properties = feature["properties"] as? NSDictionary
        let isAddress = placeID?.hasPrefix("address") == true
        let isPlace = placeID?.hasPrefix("poi") == true || placeID?.hasPrefix("neighborhood") == true

        // Parse context data
        var contextData: [String: String] = [:]
        let contextElements = feature["context"] as? [NSDictionary] ?? []
        for context in contextElements {
            guard let ID = context["id"] as? String, text = context["text"] as? String,
                IDFirstPart = ID.componentsSeparatedByString(".").first else
            {
                continue
            }

            contextData[IDFirstPart] = text
        }

        if let first = center?.first, last = center?.last {
            self.coordinate = CLLocationCoordinate2D(latitude: last, longitude: first)
        } else {
            self.coordinate = coordinate ?? kCLLocationCoordinate2DInvalid
        }

        if isAddress {
            self.thoroughfare = [feature["address"] as? String, feature["text"] as? String]
                .flatMap { $0 }
                .joinWithSeparator(" ")
        } else {
            self.thoroughfare = properties?["address"] as? String
        }

        self.placeName = isPlace ? feature["text"] as? String : nil
        self.locality = contextData["place"]
        self.administrativeArea = contextData["region"]
        self.postalCode = contextData["postcode"]
        self.country = contextData["country"]

        self.formattedAddress =
            [self.thoroughfare, self.locality, self.administrativeArea, self.postalCode, self.country]
                .flatMap { $0 }
                .joinWithSeparator(", ")
    }
}
