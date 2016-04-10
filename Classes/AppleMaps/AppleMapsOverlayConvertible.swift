import MapKit

/**
 Overlay convertibles should provide a method to convert a meta type to a concrete apple map's overlay.
 */
protocol AppleMapsOverlayConvertible: MapShape {

    /**
     Creates a new overlay and assigns the receiver meta type into the newly created overlay.

     - returns: the newly created apple map's overlay with the receiver assigned as the underlyingAnnotation.
     */
    func createAndAssignAppleMapsOverlay() -> MKOverlay
}

extension MapPolyline: AppleMapsOverlayConvertible {

    func createAndAssignAppleMapsOverlay() -> MKOverlay {
        var coordinates = self.coordinates
        let polyline = AppleMapsPolyline(coordinates: &coordinates, count: coordinates.count)
        polyline.metaPolyline = self
        self.underlyingAnnotation = polyline
        return polyline
    }
}

extension MapPolygon: AppleMapsOverlayConvertible {

    func createAndAssignAppleMapsOverlay() -> MKOverlay {
        var coordinates = self.coordinates
        let polygon = AppleMapsPolygon(coordinates: &coordinates, count: coordinates.count)
        polygon.metaPolygon = self
        self.underlyingAnnotation = polygon
        return polygon
    }
}

extension MapCircle: AppleMapsOverlayConvertible {

    func createAndAssignAppleMapsOverlay() -> MKOverlay {
        let circle = AppleMapsCircle(centerCoordinate: self.position, radius: self.radius)
        circle.metaCircle = self
        self.underlyingAnnotation = circle
        return circle
    }
}
