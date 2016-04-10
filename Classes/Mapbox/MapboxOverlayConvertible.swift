import Mapbox

/**
 Overlay convertibles should provide a method to convert a meta type to a concrete mapbox's overlay.
 */
protocol MapboxOverlayConvertible: MapShape {

    /**
     Creates a new overlay and assigns the receiver meta type into the newly created overlay.

     - returns: the newly created mapbox's overlay with the receiver assigned as the underlyingAnnotation.
     */
    func createAndAssignMapboxOverlay() -> MGLOverlay
}

extension MapPolyline: MapboxOverlayConvertible {

    func createAndAssignMapboxOverlay() -> MGLOverlay {
        var coordinates = self.coordinates
        let polyline = MapboxPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
        polyline.metaPolyline = self
        self.underlyingAnnotation = polyline
        return polyline
    }
}

extension MapPolygon: MapboxOverlayConvertible {

    func createAndAssignMapboxOverlay() -> MGLOverlay {
        var coordinates = self.coordinates
        let polygon = MapboxPolygon(coordinates: &coordinates, count: UInt(coordinates.count))
        polygon.metaPolygon = self
        self.underlyingAnnotation = polygon
        return polygon
    }
}

//extension MapCircle: MapboxOverlayConvertible {
//
//    func createAndAssignMapboxOverlay() -> MGLOverlay {
//        let circle = MapboxCircle(centerCoordinate: self.position, radius: self.radius)
//        circle.metaCircle = self
//        self.underlyingAnnotation = circle
//        return circle
//    }
//}
