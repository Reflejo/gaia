import GoogleMaps

private let kDefaultMapZoom: Float = 13.0
private let kMapMaximumZoom: Float = 18.5
private let kMapMinimumZoom: Float = 0.0

extension MapProviderIdentifier {
    public static let GoogleMaps = MapProviderIdentifier(GoogleMapsView.self)
}

final class GoogleMapsView: GMSMapView {

    private weak var providerDelegate: MapProviderDelegate?

    /// When set, the camera will automatically follow user positions
    var cameraFollowsUser: Bool = false

    /// The currently set settings for the map.
    var configuration = MapSettings() {
        willSet {
            self.myLocationEnabled = newValue.myLocationEnabled
            self.settings.indoorPicker = newValue.indoorPicker
            self.settings.myLocationButton = newValue.myLocationButton
            self.settings.rotateGestures = newValue.rotateGestures
            self.settings.tiltGestures = newValue.tiltGestures
            self.settings.allowScrollGesturesDuringRotateOrZoom =
                newValue.allowScrollGesturesDuringRotateOrZoom

            self.setMinZoom(newValue.zoomLimits.min, maxZoom: newValue.zoomLimits.max)
        }
    }

    convenience init(providerDelegate: MapProviderDelegate) {
        self.init(frame: .zero)
        self.providerDelegate = providerDelegate
        self.delegate = self
        self.configuration = MapSettings()

        self.moveCamera(GMSCameraUpdate.zoomTo(kDefaultMapZoom))
        self.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
                                         change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if self.cameraFollowsUser && !self.isAnimating,
            let location = change?[NSKeyValueChangeNewKey] as? CLLocation
        {
            self.animateToLocation(location.coordinate)
        }
    }

    deinit {
        self.removeObserver(self, forKeyPath: "myLocation")
    }
}

// MARK: - Map Provider implementation

extension GoogleMapsView: MapSDKProvider {

    static var types = MapProviderTypes(
        CameraUpdateType: GMSCameraUpdate.self,
        MarkerType: GoogleMapsMarker.self,
        MapURLTileLayerType: GMSURLTileLayer.self,
        CircleType: GMSCircle.self,
        PolylineType: GMSPolyline.self,
        PolygonType: GMSPolygon.self,
        PathType: GMSPath.self,
        UtilsType: GoogleMapsUtils.self,

        customTypes: [:]
    )

    var rendering: Bool {
        get { return self.preferredFrameRate == kGMSFrameRateMaximum }
        set { self.preferredFrameRate = newValue ? kGMSFrameRateConservative : kGMSFrameRateMaximum }
    }

    var zoom: Float { return self.camera.zoom }
    var project: MapProjection { return self.projection }

    var centerPosition: CLLocationCoordinate2D {
        return self.camera.target
    }

    var selectedMapMarker: MapMarker? {
        get { return self.selectedMarker as? MapMarker }
        set { self.selectedMarker = newValue as? GMSMarker }
    }

    static func provideAPIKey(key: String) {
        GMSServices.provideAPIKey(key)
    }

    func setPadding(padding: UIEdgeInsets, animated: Bool, alongWithAnimation: (() -> Void)?) {
        let duration = animated ? NSTimeInterval(UINavigationControllerHideShowBarDuration) : 0.0
        UIView.animateWithDuration(duration) {
            alongWithAnimation?()
            self.padding = padding
        }
    }

    func moveCameraWithUpdate(cameraUpdate: MapCameraUpdate, animated: Bool) {
        guard let cameraUpdate = cameraUpdate as? GMSCameraUpdate else {
            return
        }

        animated ? self.animateWithCameraUpdate(cameraUpdate) : self.moveCamera(cameraUpdate)
    }

    func addShape(shape: MapShape) {
        (shape as? GMSOverlay)?.map = self
    }

    func removeShape(shape: MapShape, animated: Bool) {
        assert(!(shape is GMSMarker) || !animated, "Adding non markers animated is not supported yet")

        if !animated {
            (shape as? GMSOverlay)?.map = nil
            return
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setCompletionBlock {
            (shape as? GMSOverlay)?.map = nil
        }

        (shape as? GMSMarker)?.opacity = 0.0
        CATransaction.commit()
    }
}

// MARK: - GoogleMaps Delegate implementation

extension GoogleMapsView: GMSMapViewDelegate {

    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        self.providerDelegate?.mapProvider(self, didChangeCameraPosition: position.target)
    }

    func mapView(mapView: GMSMapView, willMoveWithGesture gesture: Bool) {
        self.providerDelegate?.mapProvider(self, willMoveWithGesture: gesture)
    }

    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        self.providerDelegate?.mapProvider(self, idleAtCameraPosition: position.target)
    }

    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        guard let marker = marker as? MapMarker else {
            return false
        }

        return self.providerDelegate?.mapProvider(self, didTapMarker: marker) == true
    }

    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let marker = marker as? MapMarker else {
            return nil
        }

        return self.providerDelegate?.mapProvider(self, markerInfoWindow: marker)
    }

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        if let marker = marker as? MapMarker {
            self.providerDelegate?.mapProvider(self, didTapInfoWindowOfMarker: marker)
        }
    }
}
