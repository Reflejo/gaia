private let kMapMaximumZoom: Float = 18.5

public struct MapSettings {

    /// Controls whether tilt gestures are enabled (default) or disabled. If enabled, users may use a
    /// two-finger vertical down or up swipe to tilt the camera.
    public var tiltGestures = false

    /// Controls whether rotate gestures are enabled (default) or disabled. If enabled, users may use a
    /// two-finger rotate gesture to rotate the camera.
    public var rotateGestures = false

    /// Enables or disables the My Location button. This is a button visible on the map that, when tapped
    /// by users, will center the map on the current user location.
    public var myLocationButton = true

    /// Enables the indoor floor picker. If enabled, it is only visible when the view is focused on a building
    /// with indoor floor data.
    public var indoorPicker = false

    /// Enables or disables the My Location button. This is a button visible on the map that, when tapped
    /// by users, will center the map on the current user location.
    public var myLocationEnabled = true

    /// Controls whether rotate and zoom gestures can be performed off-center and scrolled around.
    public var allowScrollGesturesDuringRotateOrZoom = false

    /// Sets |minZoom| and |maxZoom|. This property expects the minimum to be less than or equal to the
    /// maximum.
    public var zoomLimits: (min: Float, max: Float) = (0.0, kMapMaximumZoom)
}
