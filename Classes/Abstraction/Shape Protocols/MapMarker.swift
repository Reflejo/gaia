import CoreLocation

/**
 A marker is an icon placed at a particular point on the map's surface. A marker's icon is drawn oriented
 against the device's screen rather than the map's surface.
 */
public protocol MapMarker: MapShape {

    /// Marker icon to render. If left nil, uses a default SDK place marker. Supports animated images, but
    /// each frame must be the same size or the behavior is undefined.
    var icon: UIImage? { get set }

    /// Marker position in the map
    var position: CLLocationCoordinate2D { get set }

    /// The unique identifier of the map marker, when not given a default unique key will be choosen.
    var id: String { get set }

    /// Closure that passes the tapped marker and returns true if the tap event is considered
    /// handled, otherwise false which will continue with the default marker selection behavior
    var onTap: (MapMarker -> Bool)? { get set }

    /// Called when marker's tooltip is tapped. Closure passes the tooltip's marker.
    var onTooltipTap: (MapMarker -> Void)? { get set }

    /// UIView to be displayed as a tooltip for this marker whenever marker is selected
    var tooltipView: UIView? { get set }

    /// Whether this marker's tooltip is currently visible
    var isTooltipVisible: Bool { get }

    /// The ground anchor specifies the point in the icon image that is anchored to the marker's position on
    /// the Earth's surface. This point is specified within the continuous space [0.0, 1.0] x [0.0, 1.0],
    /// where (0,0) is the top-left corner of the image, and (1,1) is the bottom-right corner.
    var groundAnchor: CGPoint { get set }

    /// Sets the rotation of the marker in degrees clockwise about the marker's anchor point. The axis of
    /// rotation is perpendicular to the marker. A rotation of 0 is the default position of the marker.
    var rotation: CLLocationDegrees { get set }

    /// If this marker should cause tap notifications
    var tappable: Bool { get set }

    /// The info window anchor specifies the point in the icon image at which to anchor the info window,
    /// which will be displayed directly above this point.
    var infoWindowAnchor: CGPoint { get set }

    /// Whether the marker will appear by using the default animation from the map SDK provider.
    var appearAnimated: Bool { get set }

    /// Sets the opacity of the marker, between 0 (completely transparent) and 1
    var opacity: Float { get set }

    /**
     Craetes a `MapMarker` instance that will be positioned on the given `position`.

     - parameter position: The earth coordinate.
     */
    init(position: CLLocationCoordinate2D)
}
