import MapKit

extension MapProviderIdentifier {
    /// Apple Maps provider
    public static let AppleMaps = MapProviderIdentifier(AppleMapsView.self, api: AppleMapsAPI.self,
                                                        name: "AppleMaps")
}

final class AppleMapsView: MKMapView {

    private weak var providerDelegate: MapProviderDelegate?
    private var padding = UIEdgeInsetsZero

    /// A boolean that indicates if the map reports to be in the middle of an animation.
    var isAnimating = false

    /// MapProjection object that you can use to convert between screen coordinates and lat/long coordinates.
    lazy var project: MapProjection = AppleMapsProjection(map: self)

    /// The currently set settings for the map.
    var configuration = MapSettings() {
        willSet {
            self.rotateEnabled = newValue.rotateGestures
            self.pitchEnabled = newValue.tiltGestures
        }
    }
}

extension AppleMapsView: MapSDKProvider {

    var myLocationEnabled: Bool {
        get { return self.showsUserLocation }
        set { self.showsUserLocation = newValue }
    }

    var selectedMapMarker: MapMarker? {
        get { return (self.selectedAnnotations.first as? AppleMapsMarker)?.metaMarker }
        set { self.selectAnnotation(newValue?.underlyingAnnotation as! MKAnnotation, animated: true) }
    }

    var centerPosition: CLLocationCoordinate2D {
        return self.centerCoordinate
    }

    var attributionView: UIView? { return nil }

    var cameraFollowsUser: Bool {
        get { return self.userTrackingMode != .None }
        set { self.userTrackingMode = self.cameraFollowsUser ? .Follow : .None }
    }

    func setNavigating(navigating: Bool) {
        if #available(iOS 9.0, *) {
            self.showsTraffic = navigating
        }

        self.showsBuildings = !navigating
        self.showsPointsOfInterest = !navigating
    }

    func addShape(shape: MapShape) {
        guard let annotation = shape as? AppleMapsOverlayConvertible else {
            assertionFailure("Tried to add a shape into AppleMaps that is not compatible.")
            return
        }

        let existingOverlay = annotation.underlyingAnnotation as? MKOverlay
        self.addOverlay(existingOverlay ?? annotation.createAndAssignAppleMapsOverlay())
    }

    func addMarker(marker: MapMarker, animated: Bool) {
        marker.delegate = self

        let existingOverlay = marker.underlyingAnnotation as? MKAnnotation
        let marker = existingOverlay ?? AppleMapsMarker(metaMarker: marker)
        self.addAnnotation(marker)
    }

    func removeAnnotation(annotation: MapAnnotation, animated: Bool) {
        guard let mapAnnotation = annotation.underlyingAnnotation as? MKAnnotation else {
            return
        }

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setCompletionBlock {
            self.removeAnnotation(mapAnnotation)
        }

        (annotation as? MapMarker)?.opacity = 0.0
        CATransaction.commit()
    }

    func setPadding(padding: UIEdgeInsets, animated: Bool, alongWithAnimation: (() -> Void)?) {
        self.padding = padding
        self.moveCameraWithAnimation(.Target(self.centerCoordinate, nil), animated: animated)

        //FIXME: Do this along with the previous animation
        alongWithAnimation?()
    }

    func moveCameraWithAnimation(animation: MapAnimation, animated: Bool) {
        switch animation {
            case .Target(let target, let zoom):
                let span = zoom.map { self.coordinateSpan(withCenter: target, zoom: $0) } ?? self.region.span
                let deltaY = (self.padding.top - self.padding.bottom) / self.bounds.size.height
                let deltaX = (self.padding.right - self.padding.left) / self.bounds.size.width

                var center = target
                center.latitude += span.latitudeDelta * Double(deltaY * 0.5)
                center.longitude += span.longitudeDelta * Double(deltaX * 0.5)
                let rect = self.mapRectFor(center: center, span: span)
                self.setVisibleMapRect(rect, animated: animated)

            case .Bounds(let bounds):
                let pointSouthWest = MKMapPointForCoordinate(bounds.southWest)
                let pointNorthEast = MKMapPointForCoordinate(bounds.northEast)
                let isAntiMeridian = bounds.northEast.longitude <= bounds.southWest.longitude
                let antimeridianOveflow = isAntiMeridian ? MKMapSizeWorld.width : 0

                let rect = MKMapRectMake(pointSouthWest.x, pointNorthEast.y,
                                         pointNorthEast.x - pointSouthWest.x + antimeridianOveflow,
                                         pointSouthWest.y - pointNorthEast.y)

                self.setVisibleMapRect(rect, edgePadding: self.padding, animated: animated)
        }
    }

    func clear() {
        self.removeOverlays(self.overlays)
        self.removeAnnotations(self.annotations)
    }

    static func provideAPIKey(key: String) {}

    convenience init(providerDelegate: MapProviderDelegate) {
        self.init(frame: .zero)

        self.providerDelegate = providerDelegate
        self.delegate = self
    }
}

extension AppleMapsView: MKMapViewDelegate {

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        guard let overlayRenderable = overlay as? AppleMapsOverlayRenderable else {
            return MKOverlayRenderer(overlay: overlay)
        }

        return overlayRenderable.overlayRenderer
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard let marker = (annotation as? AppleMapsMarker)?.metaMarker else {
            return nil
        }

        let imagePostfix = marker.icons?.normal != nil ? "-withImage" : "-noImage"
        let identifier = String(annotation.dynamicType) + imagePostfix
        var annotationView: MKAnnotationView! = self.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if annotationView == nil {
            let ViewType = marker.icons == nil ? MKPinAnnotationView.self : MKAnnotationView.self
            annotationView = ViewType.init(annotation: annotation, reuseIdentifier: identifier)
        }

        let headingInRadians = CGFloat(marker.rotation * DegreesToRadians)
        let transformation = CGAffineTransformMakeRotation(headingInRadians)
        annotationView.centerOffset = marker.groundAnchor
        annotationView.enabled = marker.tappable
        annotationView.image = marker.icons?.normal
        annotationView.alpha = CGFloat(marker.opacity)
        annotationView.layer.setAffineTransform(transformation)
        return annotationView
    }

    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.isAnimating = true
        self.providerDelegate?.mapProvider(self, willMoveWithGesture: self.duringGesture)
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.isAnimating = false
        self.providerDelegate?.mapProvider(self, idleAtCameraPosition: self.centerCoordinate)
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let marker = view.annotation as? AppleMapsMarker else {
            return
        }

        let captured = self.providerDelegate?.mapProvider(self, didTapMarker: marker.metaMarker) == true
        if !captured {
            self.moveCameraWithAnimation(.Target(marker.coordinate, nil), animated: true)
        }
    }
}
