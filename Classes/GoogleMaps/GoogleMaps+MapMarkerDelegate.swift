import GoogleMaps

extension GoogleMapsView: MapMarkerDelegate {
    func markerOpacityDidChange(marker: MapProviderAnnotation, opacity: Float) {
        (marker as? GMSMarker)?.opacity = opacity
    }

    func markerPositionDidChange(marker: MapProviderAnnotation, position: CLLocationCoordinate2D) {
        (marker as? GMSMarker)?.position = position
    }

    func markerRotationDidChange(marker: MapProviderAnnotation, rotation: CLLocationDegrees) {
        (marker as? GMSMarker)?.rotation = rotation
    }

    func markerTappableDidChange(marker: MapProviderAnnotation, tappable: Bool) {
        (marker as? GMSMarker)?.tappable = tappable
    }
}
