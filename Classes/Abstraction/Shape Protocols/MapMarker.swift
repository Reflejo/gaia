import CoreLocation

public typealias MarkerIconsType = (normal: UIImage, selected: UIImage?, highlighted: UIImage?)

/**
 A marker is an icon placed at a particular point on the map's surface. A marker's icon is drawn oriented
 against the device's screen rather than the map's surface.
 */
public class MapMarker: MapAnnotation {

    /// The delegate that will receive all the marker modifications.
    weak var delegate: MapMarkerDelegate?

    public weak var underlyingAnnotation: MapProviderAnnotation?

    /// Marker icons to render. If normal is left nil, uses a default SDK place marker.
    let icons: MarkerIconsType?

    /// The unique identifier of the map marker, when not given a default unique key will be choosen.
    let id: String

    /// The ground anchor specifies the point in the icon image that is anchored to the marker's position on
    /// the Earth's surface. This point is specified within the continuous space [0.0, 1.0] x [0.0, 1.0],
    /// where (0,0) is the top-left corner of the image, and (1,1) is the bottom-right corner.
    let groundAnchor: CGPoint

    /// Closure that passes the tapped marker and returns true if the tap event is considered
    /// handled, otherwise false which will continue with the default marker selection behavior
    public var onTap: (MapMarker -> Bool)?

    /// Sets the rotation of the marker in degrees clockwise about the marker's anchor point. The axis of
    /// rotation is perpendicular to the marker. A rotation of 0 is the default position of the marker.
    public var rotation = CLLocationDegrees(0) {
        didSet {
            if oldValue != self.rotation, let underlyingMarker = self.underlyingAnnotation {
                self.delegate?.markerRotationDidChange(underlyingMarker, rotation: self.rotation)
            }
        }
    }

    /// Marker position in the map
    public var position: CLLocationCoordinate2D {
        didSet {
            if let underlyingMarker = self.underlyingAnnotation {
                self.delegate?.markerPositionDidChange(underlyingMarker, position: self.position)
            }
        }
    }

    /// If this marker should cause tap notifications
    public var tappable = true {
        didSet {
            if oldValue != self.tappable, let underlyingMarker = self.underlyingAnnotation {
                self.delegate?.markerTappableDidChange(underlyingMarker, tappable: self.tappable)
            }
        }
    }

    /// Sets the opacity of the marker, between 0 (completely transparent) and 1
    public var opacity: Float = 1.0 {
        didSet {
            if oldValue != self.opacity, let underlyingMarker = self.underlyingAnnotation {
                self.delegate?.markerOpacityDidChange(underlyingMarker, opacity: self.opacity)
            }
        }
    }

    /// Closure called when the marker is about to get selected; this closure determines if the marker should
    /// toggle selection (selected<->unselected).
    public var shouldToggleSelection: (MapMarker -> Bool)?

    /**
     Craetes a `MapMarker` instance that will be positioned on the given `position`.

     - parameter position: The earth coordinate.
     */
    public init(position: CLLocationCoordinate2D, id: String? = nil, icon: UIImage? = nil,
                selectedIcon: UIImage? = nil, highlightedIcon: UIImage? = nil,
                groundAnchor: CGPoint = CGPoint(x: 0.5, y: 0.5))
    {
        self.position = position
        self.id = id ?? NSUUID().UUIDString
        self.icons = icon.map { ($0, selectedIcon, highlightedIcon) }
        self.groundAnchor = groundAnchor
    }
}
