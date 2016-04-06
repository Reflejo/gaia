import CoreLocation

/**
 Contains all the Types that the map provider needs to specialize. We use this types to construct concrete
 instances according to the current provider.
 */
public struct MapProviderTypes {
    /// The type that all map markers conform to. Markers contains at least a position and an icon.
    let MarkerType: MapMarker.Type

    /// Type in charge of fetch tiles based on a constructed URLs. This is used for example on Heatmaps.
    let MapURLTileLayerType: MapURLTileLayer.Type

    /// A type that creates circles on the Earth's surface (spherical cap).
    let CircleType: MapCircle.Type

    /// This type draws physical lines between a set of points.
    let PolylineType: MapPolyline.Type

    /// Defines a polygon that appears on the map. A polygon defines a series of connected coordinates in
    /// an ordered sequence.
    let PolygonType: MapPolygon.Type

    /// Provides all the geometric utilities containing the math to calculate position offsets, distance, etc.
    let UtilsType: MapUtilsProvider.Type

    /// This dictionary will contain all the registered custom types. See `Gaia.registerType`.
    var customTypes: [ObjectIdentifier: Any.Type]
}

/**
 This delegate serves as an abstraction to unify all events that any map SDK can inform back to the
 MapProvider. Map Provider's should send these events.
 */
public protocol MapProviderDelegate: class {

    /**
     Called after a marker's info window has been tapped.

     - parameter provider: The map provider that was tapped
     - parameter marker:   The marker that was tapped
     */
    func mapProvider(provider: MapSDKProvider, didTapInfoWindowOfMarker marker: MapMarker)

    /**
     Called when a marker is about to become selected, and provides an optional custom info window to use for
     that marker if this method returns a UIView.

     - parameter provider: The map provider that was pressed
     - parameter marker:   The marker that was selected

     - returns: The custom info window for the specified marker, or nil for default
     */
    func mapProvider(provider: MapSDKProvider, markerInfoWindow marker: MapMarker) -> UIView?

    /**
     Called after a marker has been tapped.

     - parameter provider: The map provider that was pressed
     - parameter marker:   The marker that was pressed

     - returns: true if this delegate handled the tap event, which prevents the map rom performing its default
                selection behavior, and false if the map should continue with its default selection behavior.
     */
    func mapProvider(provider: MapSDKProvider, didTapMarker marker: MapMarker) -> Bool

    /**
     Called when the map becomes idle, after any outstanding gestures or animations have completed (or after
     the camera has been explicitly set).

     - parameter provider:  The map provider where the camera changed occured.
     - parameter position:  The new camera center after the change
     */
    func mapProvider(provider: MapSDKProvider, idleAtCameraPosition position: CLLocationCoordinate2D)

    /**
     Called before the camera on the map changes, either due to a gesture, animation or by being updated
     explicitly without animation.

     - parameter provider: The map provider where the movement is about to start
     - parameter gesture:  If true, this is occuring due to a user gesture.
     */
    func mapProvider(provider: MapSDKProvider, willMoveWithGesture gesture: Bool)

    /**
     Called repeatedly during any animations or gestures on the map (or once, if the camera is explicitly
     set). This may not be called for all intermediate camera positions. It is always called for the final
     position of an animation or gesture.

     - parameter provider: The map provider where the movement is about to start
     - parameter position: The current center of the camera
     */
    func mapProvider(provider: MapSDKProvider, didChangeCameraPosition position: CLLocationCoordinate2D)
}

/**
 All Map SDKs implementations should conform to this protocol, which is used to specialize all Map operations.
 */
public protocol MapSDKProvider {

    /// The specialized types that the map provider defines for all our abstractions such as `MapPolyline`,
    /// `MapPolygon`, `MapMarker`, etc.
    static var types: MapProviderTypes { get set }

    /// Tells this map to power down / starts its renderer.
    var rendering: Bool { get set }

    /// The currently set settings for the map.
    var configuration: MapSettings { get set }

    /// The view that contains the map tiles (it's usually the provider itself but it doesn't have to be)
    var view: UIView { get }

    /// A boolean that indicates if the map reports to be in the middle of an animation.
    var isAnimating: Bool { get }

    /// When set, the camera will automatically follow user positions
    var cameraFollowsUser: Bool { get set }

    /// The marker that is selected.  Setting this property selects a particular marker, showing an info
    /// window on it. If it's non-nil, setting it to nil deselects the marker, hiding the info window.
    var selectedMapMarker: MapMarker? { get set }

    /// Zoom level. Zoom uses an exponentional scale, where zoom 0 represents the entire world as a 256 x 256
    /// square. Each successive zoom level increases magnification by a factor of 2.
    var zoom: Float { get }

    /// A boolean that indicates if the map is being move using a gesture recognizer.
    var duringGesture: Bool { get }

    /// Number of touches on the screen for the running gesture.
    var touchesInScreen: Int { get }

    /// Whether the user's location is displayed on the map.
    var myLocationEnabled: Bool { get set }

    /// The geo location of the center point of the mapTypeng gs
    var centerPosition: CLLocationCoordinate2D { get }

    /// A view showing legally required copyright notices, positioned at the bottom-right of the map view.
    var attributionView: UIView? { get }

    /// MapProjection object that you can use to convert between screen coordinates and lat/long coordinates.
    var project: MapProjection { get }

    /**
     Provides your API key to the Map Provider SDK. This needs to be called once, before any operation.

     - parameter key: The Provider SDK key.
     */
    static func provideAPIKey(key: String)

    /**
     Switches to navigation mode. This mode shows the streets labels bigger and replaces the blue dot for a
     navigation icon that follows the user's heading. Default implementation is a no-op.

     - parameter navigating: A boolean indicating if navigation mode should be enabled (true) or disabled
                             (false).
     */
    func setNavigating(navigating: Bool)

    /**
     When padding is set we need to adjust the static pin y-center (animated).

     - parameter padding:  All map calculations will take this inset into consideration. If the padding is
                           not balanced, the visual center of the view will move as appropriate
     - parameter animated: When true, the padding delta will be animated by moving the map and the static pin
     */
    func setPadding(padding: UIEdgeInsets, animated: Bool, alongWithAnimation: (() -> Void)?)

    /**
     Clears all markup that has been added to the map, including markers, polylines and ground overlays.
     */
    func clear()

    /**
     Applies |cameraUpdate| to the current camera. The transition might be animated by setting animated
     to true.

     - parameter cameraUpdate: The camera update to apply.
     - parameter animated:     A flag indicating whether the update should be animated or not.
     */
    func moveCameraWithAnimation(animation: MapAnimation, animated: Bool)

    /**
     Add shape into the map view.

     - parameter shape: The shape to add to the receiver. The map view retains the MapShape object.
     */
    func addShape(shape: MapShape)

    /**
     Removes an annotation from the map view, deselecting it if it is selected. Removing an annotation object
     dissociates it from the map view entirely, preventing it from being displayed on the map.

     - parameter shape:    The shape to remove.
     - parameter animated: Whether the shape should fade out before being removed.
     */
    func removeShape(shape: MapShape, animated: Bool)

    /**
     Creates a new instance of the map view by setting the provider delegate.

     - parameter providerDelegate: The provider delegate that will be used to capture map events using; note
                                   that this delegate is a unification that can be used for any SDK.

     - returns: the newly created MapViewProvider
     */
    init(providerDelegate: MapProviderDelegate)
}

extension MapSDKProvider where Self: UIView {
    var view: UIView { return self }
}
