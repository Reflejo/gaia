import Mapbox

private let kDefaultMapZoom = 13.0

extension MapProviderIdentifier {
    public static let Mapbox = MapProviderIdentifier(MapboxView.self)
}

final class MapboxView: MGLMapView {

    private weak var providerDelegate: MapProviderDelegate?

    /// A boolean that indicates if the map reports to be in the middle of an animation.
    var isAnimating = false

    /// The currently set settings for the map.
    var configuration = MapSettings() {
        willSet {
            self.showsUserLocation = newValue.myLocationEnabled
            self.rotateEnabled = newValue.rotateGestures
            self.pitchEnabled = newValue.tiltGestures

            self.minimumZoomLevel = Double(newValue.zoomLimits.min)
            self.maximumZoomLevel = Double(newValue.zoomLimits.max)
        }
    }

    convenience init(providerDelegate: MapProviderDelegate) {
        self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        self.providerDelegate = providerDelegate
        self.delegate = self

        dispatch_async(dispatch_get_main_queue()) {
            self.setZoomLevel(kDefaultMapZoom, animated: false)
        }
    }
}

// MARK: - Map Provider implementation

extension MapboxView: MapSDKProvider {

    static var types = MapProviderTypes(
        MarkerType: MapboxMarker.self,
        MapURLTileLayerType: MapboxURLTileLayer.self,
        CircleType: MapboxCircle.self,
        PolylineType: MapboxPolyline.self,
        PolygonType: MapboxPolygon.self,
        UtilsType: MapboxUtils.self,

        customTypes: [:]
    )

    var cameraFollowsUser: Bool {
        get { return self.userTrackingMode != .None }
        set { self.userTrackingMode = .Follow }
    }

    var zoom: Float { return Float(self.zoomLevel) }
    var project: MapProjection { return MapboxProjection(map: self) }
    var attributionView: UIView? { return self.attributionButton }

    /// FIXME: Implement this on Mapbox
    var rendering: Bool {
        get { return true }
        set { }
    }

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

    var touchesInScreen: Int {
        return self.gestureRecognizers?
            .map { $0.numberOfTouches() }
            .maxElement() ?? 0
    }

    var duringGesture: Bool {
        return self.touchesInScreen > 0
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
                print(target)
                self.setCenterCoordinate(target, animated: animated)

            case .Target(let target, let zoom):
                self.setCenterCoordinate(target, zoomLevel: Double(zoom ?? 0.0), animated: animated)

            case .Bounds(let bounds):
                let bounds = MGLCoordinateBounds(sw: bounds.southWest, ne: bounds.northEast)
                self.setVisibleCoordinateBounds(bounds, animated: animated)
        }
    }

    func addShape(shape: MapShape) {
        guard let annotation = shape as? MGLAnnotation else {
            assertionFailure("Tried to add a shape into Mapbox that is not compatible. Check Gaia.SDK.")
            return
        }

        (shape as? MapboxMarker)?.map = self
        self.addAnnotation(annotation)
    }

    func clear() {
        self.removeAnnotations(self.annotations ?? [])
    }

    /// FIXME: Do something here to support navigation
    func setNavigating(navigating: Bool) {}

    // FIXME: Support shape removal animated.
    func removeShape(shape: MapShape, animated: Bool) {
        assert(!animated, "Mapbox doesn't support animations when removing markers yet.")

        guard let annotation = shape as? MGLAnnotation else {
            assertionFailure("Tried to remove a shape into Mapbox that is not compatible. Check Gaia.SDK.")
            return
        }

        self.removeAnnotation(annotation)
    }
}

// MARK: - GoogleMaps Delegate implementation

extension MapboxView: MGLMapViewDelegate {

    public func mapViewRegionIsChanging(mapView: MGLMapView) {
        self.isAnimating = true
        self.providerDelegate?.mapProvider(self, didChangeCameraPosition: self.centerCoordinate)
    }

    public func mapView(mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
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
        guard let image = (annotation as? MapMarker)?.icon else {
            return nil
        }

        return MGLAnnotationImage(image: image, reuseIdentifier: "")
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return (annotation as? MapMarker)?.tooltipView != nil
    }

    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return (annotation as? MapMarker).map { CGFloat($0.opacity) } ?? 1.0
    }

    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return (annotation as? MapOverlay)?.strokeLineColor ?? .blackColor()
    }

    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return (annotation as? MapPolygon)?.fillColor ?? .blackColor()
    }

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return (annotation as? MapOverlay)?.strokeWidth ?? 1.0
    }
}
