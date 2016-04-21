import MapKit

extension AppleMapsView: MapMarkerDelegate {

    func animate(marker: MapProviderAnnotation, duration: NSTimeInterval, options: UIViewAnimationOptions,
                 animations: () -> Void, completion: (Bool -> Void)?)
    {
        UIView.animateWithDuration(duration, delay: 0.0, options: options,
                                   animations: animations, completion: completion)
    }

    func markerOpacityDidChange(marker: MapProviderAnnotation, opacity: Float) {
        guard let annotation = marker as? MKAnnotation, view = self.viewForAnnotation(annotation) else {
            return
        }

        view.alpha = CGFloat(opacity)
    }

    func markerPositionDidChange(marker: MapProviderAnnotation, position: CLLocationCoordinate2D) {
        (marker as? MKPointAnnotation)?.coordinate = position
    }

    func markerRotationDidChange(marker: MapProviderAnnotation, rotation: CLLocationDegrees) {
        guard let annotation = marker as? MKAnnotation, view = self.viewForAnnotation(annotation) else {
            return
        }

        let headingInRadians = CGFloat(rotation * DegreesToRadians)
        view.transform = CGAffineTransformMakeRotation(headingInRadians)
    }

    func markerTappableDidChange(marker: MapProviderAnnotation, tappable: Bool) {
        guard let annotation = marker as? MKAnnotation, view = self.viewForAnnotation(annotation) else {
            return
        }

        view.enabled = tappable
    }
}
