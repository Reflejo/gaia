import CoreLocation

/**
 This abstraction allows map SDKs to provide an implementation for camera position properties. This is used
 for example by MapView to provide animations.
 */
public protocol MapCameraUpdate {

    /**
     Returns a class implementing MapCameraUpdate that sets the camera target to the specified coordinate.

     - parameter target: The target position coordinate.

     - returns: the newly created MapCameraUpdate concrete class
     */
    static func withTarget(target: CLLocationCoordinate2D) -> MapCameraUpdate

    /**
     Returns a class implementing MapCameraUpdate that sets the camera target and zoom to the specified
     values.

     - parameter target: The target position coordinate.
     - parameter zoom:   The target map zoom.

     - returns: the newly created MapCameraUpdate concrete class
     */
    static func withTarget(target: CLLocationCoordinate2D, zoom: Float) -> MapCameraUpdate

    /**
     Returns a MapCameraUpdate that transforms the camera such that the specified bounds are centered on
     screen at the greatest possible zoom level.

     The returned camera update will set the camera's bearing and tilt to their default zero values
     (i.e., facing north and looking directly at the Earth).
     */
    static func fitBounds(bounds: CoordinateBounds) -> MapCameraUpdate
}
