import GoogleMaps

extension MapProviderIdentifier {
    /// Google Maps provider
    public static let GoogleMaps = MapProviderIdentifier(GoogleMapsView.self, name: "GoogleMaps")
}

final class GoogleMapsView: GMSMapView {

    private weak var providerDelegate: MapProviderDelegate?

    /// When set, the camera will automatically follow user positions
    var cameraFollowsUser: Bool = false

    /// The currently set settings for the map.
    var configuration = MapSettings() {
        willSet {
            self.settings.indoorPicker = false
            self.settings.myLocationButton = false
            self.settings.rotateGestures = newValue.rotateGestures
            self.settings.tiltGestures = newValue.tiltGestures
            self.settings.allowScrollGesturesDuringRotateOrZoom =
                newValue.allowScrollGesturesDuringRotateOrZoom

            self.setMinZoom(newValue.zoomLimits.min, maxZoom: newValue.zoomLimits.max)
        }
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
        get { return (self.selectedMarker as? GoogleMapsMarker)?.metaMarker }
        set { self.selectedMarker = newValue?.underlyingAnnotation as? GoogleMapsMarker }
    }

    static func provideAPIKey(key: String) {
        GMSServices.provideAPIKey(key)
    }

    func setPadding(padding: UIEdgeInsets, animated: Bool, alongWithAnimation: (() -> Void)?) {
        let duration = animated ? NSTimeInterval(0.3) : 0.0
        UIView.animateWithDuration(duration) {
            alongWithAnimation?()
            self.padding = padding
        }
    }

    func moveCameraWithAnimation(animation: MapAnimation, animated: Bool) {
        let cameraUpdate: GMSCameraUpdate
        switch animation {
            case .Bounds(let bounds):
                let bounds = GMSCoordinateBounds(coordinate: bounds.northEast, coordinate: bounds.southWest)
                cameraUpdate = GMSCameraUpdate.fitBounds(bounds, withPadding: 0.0)

            case .Target(let target, nil):
                cameraUpdate = GMSCameraUpdate.setTarget(target)

            case .Target(let target, let zoom):
                cameraUpdate =  GMSCameraUpdate.setTarget(target, zoom: zoom ?? 0.0)
        }

        self.animateWithCameraUpdate(cameraUpdate)
    }

    func addMarker(marker: MapMarker, animated: Bool) {
        let existingMarker = marker.underlyingAnnotation as? GMSMarker
        marker.delegate = self

        let marker = existingMarker ?? GoogleMapsMarker(metaMarker: marker)
        marker.appearAnimation = animated ? kGMSMarkerAnimationPop : kGMSMarkerAnimationNone
        marker.map = self
    }

    func addShape(shape: MapShape) {
        guard let annotation = shape as? GoogleAnnotationConvertible else {
            assertionFailure("Tried to add a shape into GoogleMaps that is not compatible.")
            return
        }

        let existingShape = shape.underlyingAnnotation as? GMSOverlay
        let googleAnnotation = existingShape ?? annotation.createAndAssignGoogleMapsOverlay()
        googleAnnotation.map = self
    }

    func removeAnnotation(annotation: MapAnnotation, animated: Bool) {
        guard let annotation = annotation.underlyingAnnotation as? GMSOverlay else {
            return
        }

        guard animated, let marker = annotation as? GMSMarker else {
            annotation.map = nil
            return
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setCompletionBlock {
            marker.map = nil
        }

        marker.opacity = 0.0
        CATransaction.commit()
    }

    convenience init(providerDelegate: MapProviderDelegate) {
        self.init(frame: .zero)
        self.providerDelegate = providerDelegate
        self.delegate = self
        self.configuration = MapSettings()

        self.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
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
        guard let marker = marker as? GoogleMapsMarker else {
            return false
        }

        return self.providerDelegate?.mapProvider(self, didTapMarker: marker.metaMarker) == true
    }

    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let marker = marker as? GoogleMapsMarker else {
            return nil
        }

        return self.providerDelegate?.mapProvider(self, markerInfoWindow: marker.metaMarker)
    }

    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        if let marker = marker as? GoogleMapsMarker {
            self.providerDelegate?.mapProvider(self, didTapInfoWindowOfMarker: marker.metaMarker)
        }
    }
}
