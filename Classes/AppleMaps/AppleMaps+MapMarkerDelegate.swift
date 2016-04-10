import MapKit

extension AppleMapsView: MapMarkerDelegate {

    func markerOpacityDidChange(marker: MapProviderAnnotation, opacity: Float) {
        guard let annotation = marker as? MKAnnotation else {
            return
        }

        let duration = CATransaction.animationDuration()
        let completion = CATransaction.completionBlock()
        let annotationView = self.viewForAnnotation(annotation)
        UIView.animateWithDuration(
            duration, delay: 0.0, options: .CurveLinear,
            animations: { annotationView?.alpha = CGFloat(opacity) },
            completion: { _ in
                CATransaction.setCompletionBlock(nil)
                completion?()
            })
    }

    func markerPositionDidChange(marker: MapProviderAnnotation, position: CLLocationCoordinate2D) {
        let duration = CATransaction.animationDuration()
        let completion = CATransaction.completionBlock()

        UIView.animateWithDuration(
            duration, delay: 0.0, options: .CurveLinear,
            animations: { (marker as? MKPointAnnotation)?.coordinate = position },
            completion: { _ in
                CATransaction.setCompletionBlock(nil)
                completion?()
            })
    }

    func markerRotationDidChange(marker: MapProviderAnnotation, rotation: CLLocationDegrees) {
        guard let annotation = marker as? MKAnnotation, view = self.viewForAnnotation(annotation) else {
            return
        }

        let completion = CATransaction.completionBlock()
        let duration = CATransaction.animationDuration()

        let headingInRadians = CGFloat(rotation * DegreesToRadians)
        let transformation = CGAffineTransformMakeRotation(headingInRadians)
        UIView.animateWithDuration(
            duration, delay: 0.0, options: .CurveLinear,
            animations: { view.layer.setAffineTransform(transformation) },
            completion: { _ in
                CATransaction.setCompletionBlock(nil)
                completion?()
            })

    }

    func markerTappableDidChange(marker: MapProviderAnnotation, tappable: Bool) {
        guard let annotation = marker as? MKAnnotation, view = self.viewForAnnotation(annotation) else {
            return
        }

        view.enabled = tappable
    }
}
