import Mapbox

public final class MapboxMarker: MGLPointAnnotation, MapMarker {
    weak var map: MapboxView?

    public var icon: UIImage?
    public var id: String = ""
    public var onTap: (MapMarker -> Bool)?
    public var onTooltipTap: (MapMarker -> Void)?
    public var tooltipView: UIView?
    public var isTooltipVisible: Bool {
        return self.tooltipView != nil && self.map?.selectedMapMarker === self
    }

    public override var coordinate: CLLocationCoordinate2D {
        didSet {
            self.map?.addShape(self)
            self.map?.removeShape(self, animated: false)
        }
    }

    public var position: CLLocationCoordinate2D {
        get { return self.coordinate }
        set { self.coordinate = newValue }
    }

    /// FIXME: Implement this here using DisplayLinks after
    /// https://github.com/mapbox/mapbox-gl-native/issues/837
    public var appearAnimated: Bool {
        get { return false }
        set { assertionFailure("Markers appearing animated are not supported on Mapbox yet.") }
    }


    /// FIXME: Implement this after: https://github.com/mapbox/mapbox-gl-native/pull/3220
    public var groundAnchor: CGPoint {
        get { return CGPoint(x: 0.5, y: 0.5) }
        set { }
    }

    /// FIXME: Implement this after: https://github.com/mapbox/mapbox-gl-native/pull/3220
    public var rotation: CLLocationDegrees {
        get { return 0.0 }
        set {}
    }

    public var tappable = true

    /// FIXME: Implement this after: https://github.com/mapbox/mapbox-gl-native/issues/837
    public var zIndex: Int32 = 0

    public var opacity: Float = 1.0

    /// FIXME: Implement this after: https://github.com/mapbox/mapbox-gl-native/pull/3220
    public var infoWindowAnchor: CGPoint {
        get { return CGPoint(x: 0.5, y: 0.5) }
        set { }
    }

    public init(position: CLLocationCoordinate2D) {
        super.init()
        self.coordinate = position
    }
}
