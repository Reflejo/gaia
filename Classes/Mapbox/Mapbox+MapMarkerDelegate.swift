import Mapbox

extension MapboxView: MapMarkerDelegate {


    func animate(marker: MapProviderAnnotation, duration: NSTimeInterval, options: UIViewAnimationOptions,
                 animations: () -> Void, completion: (Bool -> Void)?)
    {
        animations()

        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            completion?(false)
        }
    }

    func markerOpacityDidChange(marker: MapProviderAnnotation, opacity: Float) {
        guard let annotation = marker as? MGLAnnotation else {
            return
        }

        self.addAnnotation(annotation)
    }

    func markerPositionDidChange(marker: MapProviderAnnotation, position: CLLocationCoordinate2D) {
        guard let annotation = marker as? MGLPointAnnotation else {
            return
        }

        annotation.coordinate = position
        self.addAnnotation(annotation)
        self.removeAnnotation(annotation)
    }

    func markerRotationDidChange(marker: MapProviderAnnotation, rotation: CLLocationDegrees) {
    }

    func markerTappableDidChange(marker: MapProviderAnnotation, tappable: Bool) {
    }
}
