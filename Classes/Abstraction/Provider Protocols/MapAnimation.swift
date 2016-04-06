import CoreLocation

/**
 Enum containing every possible map animation with its properties

 - Target: When the animation is changing the map center and/or the zoom based on a target location.
 - Bounds: When the animation is changing the map center and zoom based on a coordinate bounds.
 */
public enum MapAnimation {
    case Target(CLLocationCoordinate2D, Float?)
    case Bounds(CoordinateBounds)

    /// The center point of the map after the animation is performed
    var target: CLLocationCoordinate2D {
        switch self {
            case Target(let target, let zoom):
                return target

            case Bounds(let bounds):
                return bounds.center
        }
    }
}
