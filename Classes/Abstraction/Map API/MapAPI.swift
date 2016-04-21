import CoreLocation

/**
 Traveling profile (e.g. walking, driving, cyling, etc)

 - Driving: Whether the API should bias the results based on the user driving
 - Walking: Whether the API should bias the results based on the user walking
 - Cycling: Whether the API should bias the results based on the user cycling
 */
public enum MapTravelProfile {
    case Driving, Walking, Cycling
}

/**
 A generic error enum that contains all possible errors returned by the API.

 - Error:         A generic error with a description (this is for example HTTP errors, time outs, etc).
 - UnknownError:  An error that wasn't recognized. This is the last resource fallback.
 - ParsingError:  An error triggered while trying to parse an API response but the expected structure doesn't
                  match the returned json.
 - QuotaExceeded: The quota limit for the API was exceeded.
 */
public enum MapAPIError {
    case Error(error: String)
    case UnknownError
    case ParsingError
    case QuotaExceeded
}

/**
 The response is either an error or a type defined on the API call by generics.

 - Error:    Whether the response returned an error (see `MapAPIError`)
 - Success:  Whether the response was successful; the associated value will be the model defined by the call.
 */
public enum MapAPIResponse<SuccessType> {
    case Error(MapAPIError)
    case Success(SuccessType)

    /// When the response is an error this property returns the error object; otherwise nil.
    var error: MapAPIError? {
        switch self {
            case Error(let error):
                return error

            case Success:
                return nil
        }
    }
}

/**
 A MapAPIProvider defines the logic to allow programmatic access to the provider's tools and services such as
 geocoding, directions, place search.
 */
public protocol MapAPIProvider {

    /// The API key that will be used for authenticated calls.
    static var APIKey: String? { get set }

    /**
     Reverse geocodes a coordinate on the Earth's surface.

     - parameter coordinate: The coordinate to reverse geocode.
     - parameter completion: The callback to invoke with the reverse geocode results.
     */
    func reverseGeocode(coordinate coordinate: CLLocationCoordinate2D,
                                   completion: MapAPIResponse<[MapPlace]> -> Void)

    /**
     Returns an estimate of the place where the device is currently known to be located.

     - parameter completion: The closure to invoke with the places list.
     */
    func searchNearbyPlaces(completion: MapAPIResponse<[MapPlace]> -> Void)

    /**
     Autocompletes a given text query. Results may optionally be biased towards a certain bounds.

     - parameter query:      The partial text to autocomplete.
     - parameter bounds:     The bounds used to bias the results. This is not a hard restrict - places may
                             still be returned outside of these bounds.
     - parameter completion: The closure to invoke with the places.
     */
    func autocompleteQuery(query: String, bounds: CoordinateBounds?,
                           completion: MapAPIResponse<[MapPlace]> -> Void)

    /**
     Retrieve directions between waypoints. This will include the route's geometry.

     - parameter wayPoints:  A list of coordinate pairs to visit in order, containing at least two elements
                             (origin and destination).
     - parameter profile:    Routing profile (e.g Driving).
     - parameter completion: The closure to invoke with all legs in the same order as the given wayPoints.
     */
    func directions(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                    completion: MapAPIResponse<([[CLLocationCoordinate2D]], ETAs: [NSTimeInterval])> -> Void)

    /**
     Returns all travel times between many points. When for example [A, B, C, D] is given, this method will
     calculate the distances between A->B; B->C; C->D.

     - parameter wayPoints:  An array of locations.
     - parameter profile:    Routing profile (e.g Driving).
     - parameter completion: A closure that will be invoked with the resulting times in the same order as 
                             wayPoints. Note that the result count will be wayPoints.count - 1.
     */
    func timeEstimated(wayPoints wayPoints: [CLLocationCoordinate2D], profile: MapTravelProfile,
                                 completion: MapAPIResponse<[NSTimeInterval]> -> Void)

    /**
     Creates a concrete provider API.
     */
    init()
}

/**
 Creates a concrete provider API based on the given provider identifier.

 - parameter providerIdentifier: The provider identifier used to select the APIProvider (e.g. .GoogleMaps)

 - returns: the newly created concrete MapAPIProvider instance.
 */
public func MapAPI(provider providerIdentifier: MapProviderIdentifier) -> MapAPIProvider {
    return providerIdentifier.APIProvider.init()
}
