private let kMapMaximumZoom: Float = 18.5

public struct MapSettings {

    /// Controls whether tilt gestures are enabled (default) or disabled. If enabled, users may use a
    /// two-finger vertical down or up swipe to tilt the camera.
    public var tiltGestures = false

    /// Controls whether rotate gestures are enabled (default) or disabled. If enabled, users may use a
    /// two-finger rotate gesture to rotate the camera.
    public var rotateGestures = false

    /// Controls whether rotate and zoom gestures can be performed off-center and scrolled around.
    public var allowScrollGesturesDuringRotateOrZoom = false

    /// Sets |minZoom| and |maxZoom|. This property expects the minimum to be less than or equal to the
    /// maximum.
    public var zoomLimits: (min: Float, max: Float) = (0.0, kMapMaximumZoom)
}
