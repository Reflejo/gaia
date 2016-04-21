import Mapbox

extension MapProviderIdentifier {
    /// Mapbox SDK provider
    public static let Mapbox = MapProviderIdentifier(MapboxView.self, api: MapboxAPI.self, name: "Mapbox")
}

final class MapboxView: MGLMapView {

    private weak var providerDelegate: MapProviderDelegate?

    /// A boolean that indicates if the map reports to be in the middle of an animation.
    var isAnimating = false

    /// MapProjection object that you can use to convert between screen coordinates and lat/long coordinates.
    lazy var project: MapProjection = MapboxProjection(map: self)

    /// The currently set settings for the map.
    var configuration = MapSettings() {
        willSet {
            self.rotateEnabled = newValue.rotateGestures
            self.pitchEnabled = newValue.tiltGestures

            self.minimumZoomLevel = Double(newValue.zoomLimits.min)
            self.maximumZoomLevel = Double(newValue.zoomLimits.max)
        }
    }
}

// MARK: - Map Provider implementation

extension MapboxView: MapSDKProvider {

    var cameraFollowsUser: Bool {
        get { return self.userTrackingMode != .None }
        set { self.userTrackingMode = self.cameraFollowsUser ? .Follow : .None }
    }

    var zoom: Float { return Float(self.zoomLevel) }
    var attributionView: UIView? { return self.attributionButton }

    var myLocationEnabled: Bool {
        get { return self.showsUserLocation }
        set { self.showsUserLocation = newValue }
    }

    var centerPosition: CLLocationCoordinate2D {
        return self.centerCoordinate
    }

    var selectedMapMarker: MapMarker? {
        get { return self.selectedAnnotations.first as? MapMarker }
        set { self.selectAnnotation(newValue as! MGLAnnotation, animated: true) }
    }

    static func provideAPIKey(key: String) {
        MGLAccountManager.setAccessToken(key)
    }

    func setPadding(padding: UIEdgeInsets, animated: Bool, alongWithAnimation: (() -> Void)?) {
        self.setContentInset(padding, animated: animated)
        UIView.animateWithDuration(animated ? 0.3 : 0.0) { alongWithAnimation?() }
    }

    func moveCameraWithAnimation(animation: MapAnimation, animated: Bool) {
        switch animation {
            case .Target(let target, nil):
                self.setCenterCoordinate(target, animated: animated)

            case .Target(let target, let zoom):
                let zoom = zoom.map { Double($0 - 1) } ?? 0.0
                self.setCenterCoordinate(target, zoomLevel: zoom, animated: animated)

            case .Bounds(let bounds):
                let bounds = MGLCoordinateBounds(sw: bounds.southWest, ne: bounds.northEast)
                self.setVisibleCoordinateBounds(bounds, animated: true)
        }
    }

    func addShape(shape: MapShape) {
        guard let annotation = shape as? MapboxOverlayConvertible else {
            assertionFailure("Tried to add a shape into Mapbox that is not compatible.")
            return
        }

        self.addOverlay(annotation.createAndAssignMapboxOverlay())
    }

    func addMarker(marker: MapMarker, animated: Bool) {
        let marker = MapboxMarker(metaMarker: marker)
        marker.metaMarker.delegate = self
        self.addAnnotation(marker)
    }

    // FIXME: Support shape removal animated.
    func removeAnnotation(annotation: MapAnnotation, animated: Bool) {
        guard let annotation = annotation.underlyingAnnotation as? MGLAnnotation else {
            assertionFailure("Tried to remove a shape into Mapbox that is not compatible.")
            return
        }

        self.removeAnnotation(annotation)
    }

    func clear() {
        self.removeAnnotations(self.annotations ?? [])
    }

    /// FIXME: Do something here to support navigation
    func setNavigating(navigating: Bool) {}

    convenience init(providerDelegate: MapProviderDelegate) {
        self.init(frame: .zero)
        self.providerDelegate = providerDelegate
        self.delegate = self
    }
}

// MARK: - GoogleMaps Delegate implementation

extension MapboxView: MGLMapViewDelegate {

    func mapViewRegionIsChanging(mapView: MGLMapView) {
        self.isAnimating = true
        self.providerDelegate?.mapProvider(self, didChangeCameraPosition: self.centerCoordinate)
    }

    func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        self.isAnimating = true
        self.providerDelegate?.mapProvider(self, willMoveWithGesture: self.duringGesture)
    }

    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        self.isAnimating = false
        self.providerDelegate?.mapProvider(self, idleAtCameraPosition: self.centerCoordinate)
    }

    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        guard let marker = annotation as? MapMarker else {
            return
        }

        self.providerDelegate?.mapProvider(self, didTapMarker: marker)
    }

    func mapView(mapView: MGLMapView, calloutViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        guard let marker = annotation as? MapMarker else {
            return nil
        }

        return self.providerDelegate?.mapProvider(self, markerInfoWindow: marker)
    }

    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
        if let marker = annotation as? MapMarker {
            self.providerDelegate?.mapProvider(self, didTapInfoWindowOfMarker: marker)
        }
    }

    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard let icons = (annotation as? MapboxMarker)?.metaMarker.icons else {
            return nil
        }

        return MGLAnnotationImage(image: icons.normal, reuseIdentifier: "")
    }

    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        guard let marker = annotation as? MapboxMarker else {
            return 1.0
        }

        return CGFloat(marker.metaMarker.opacity)
    }

    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        switch annotation {
            case let polygon as MapboxPolygon:
                return polygon.metaPolygon?.strokeColor ?? .blackColor()

            case let polyline as MapboxPolyline:
                return polyline.metaPolyline?.strokeColor ?? .blackColor()

            default:
                return .blackColor()
        }
    }

    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return (annotation as? MapboxPolygon)?.metaPolygon?.fillColor ?? .blackColor()
    }

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return (annotation as? MapboxPolyline)?.metaPolyline?.strokeWidth ?? 1.0
    }
}
