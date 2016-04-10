import GoogleMaps

/**
 Overlay convertibles should provide a method to convert a meta type to a concrete google map's overlay.
 */
protocol GoogleAnnotationConvertible {

    /**
     Creates a new overlay and assigns the receiver meta type into the newly created overlay.

     - returns: the newly created google map's overlay with the receiver assigned as the underlyingAnnotation.
     */
    func createAndAssignGoogleMapsOverlay() -> GMSOverlay
}

extension MapPolygon: GoogleAnnotationConvertible {

    func createAndAssignGoogleMapsOverlay() -> GMSOverlay {
        let path = GMSMutablePath()
        self.coordinates.forEach(path.addCoordinate)

        let polygon = GMSPolygon(path: path)
        polygon.strokeWidth = self.strokeWidth
        polygon.strokeColor = self.strokeColor
        polygon.fillColor = self.fillColor

        self.underlyingAnnotation = polygon
        return polygon
    }
}

extension MapPolyline: GoogleAnnotationConvertible {

    func createAndAssignGoogleMapsOverlay() -> GMSOverlay {
        let path = GMSMutablePath()
        self.coordinates.forEach(path.addCoordinate)

        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = self.strokeColor
        polyline.strokeWidth = self.strokeWidth

        self.underlyingAnnotation = polyline
        return polyline
    }
}

extension MapCircle: GoogleAnnotationConvertible {

    func createAndAssignGoogleMapsOverlay() -> GMSOverlay {
        let circle = GMSCircle(position: self.position, radius: self.radius)

        self.underlyingAnnotation = circle
        return circle
    }
}

extension GMSOverlay: MapProviderAnnotation {}

//extension MapURLTileLayer: GoogleAnnotationConvertible {
//
//    func toGoogleAnnotation() -> GMSOverlay {
//        return GMSURLTileLayer(URLConstructor: self.constructor)
//    }
//}
