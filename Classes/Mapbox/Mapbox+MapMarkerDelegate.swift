import Mapbox

extension MapboxView: MapMarkerDelegate {

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
