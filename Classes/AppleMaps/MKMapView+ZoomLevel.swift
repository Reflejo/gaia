import MapKit

extension MKMapView {

    /// Zoom level. Zoom uses an exponentional scale, where zoom 0 represents the entire world as a 256 x 256
    /// square. Each successive zoom level increases magnification by a factor of 2.
    var zoom: Float {
        let longitudeDelta = Double(self.region.span.longitudeDelta)
        let x = longitudeDelta * MercatorRadius / Double(self.bounds.size.width * 2)
        return Float(20.00 - log2(x * DegreesToRadians))
    }

    /**
     Returns the map rect that fits the given zoom with center on the given point.

     - parameter center:   The target center.
     - parameter zoom:     The resulting zoom level.

     - returns: the biggest rect that fits the given zoom with `center`.
     */
    func mapRectFor(center center: CLLocationCoordinate2D, zoom: Float? = nil) -> MKMapRect {
        let span = zoom.map { self.coordinateSpan(withCenter: center, zoom: min($0, 28)) } ?? self.region.span
        return self.mapRectFor(center: center, span: span)
    }

    /**
     Returns the map rect that fits the given center and span.

     - parameter center:   The target center.
     - parameter zoom:     The region span to calculate the resulting map rect.

     - returns: the biggest rect that fits the given span with `center`.
     */
    func mapRectFor(center center: CLLocationCoordinate2D, span: MKCoordinateSpan) -> MKMapRect {
        let pointA = MKMapPointForCoordinate(
            CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2.0,
                                   longitude: center.longitude - span.latitudeDelta / 2.0)
        )
        let pointB = MKMapPointForCoordinate(
            CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2.0,
                                   longitude: center.longitude + span.latitudeDelta / 2.0)
        )

        return MKMapRectMake(min(pointA.x, pointB.x), min(pointA.y, pointB.y),
                             abs(pointA.x - pointB.x), abs(pointA.y - pointB.y));
    }

    /**
     Creates a Coordinate span with center on the given point and a given zoom level.

     - parameter center: The center of the resulting span.
     - parameter zoom:   The zoom level that will describe the size of the span.

     - returns: thew newly created coordinate span.
     */
    func coordinateSpan(withCenter center: CLLocationCoordinate2D, zoom: Float) -> MKCoordinateSpan {
        // Convert center coordiate to pixel space
        let centerPoint = MKMapPointForCoordinate(center)

        // Determine the scale value from the zoom level
        let zoomScale = pow(2.0, 20.0 - Double(zoom))

        // Scale the map’s size in pixel space
        let scaledMapWidth = Double(self.bounds.size.width) * zoomScale
        let scaledMapHeight = Double(self.bounds.size.height) * zoomScale

        // figure out the position of the top-left pixel
        let topLeftPointX = centerPoint.x - round(scaledMapWidth * 0.5)
        let topLeftPointY = centerPoint.y - round(scaledMapHeight * 0.5)

        // find delta between left and right longitudes
        let minCoordinate = MKCoordinateForMapPoint(MKMapPoint(x: topLeftPointX, y: topLeftPointY))
        let maxCoordinate = MKCoordinateForMapPoint(
            MKMapPoint(x: topLeftPointX + scaledMapWidth, y: topLeftPointY + scaledMapHeight)
        )

        let longitudeDelta = maxCoordinate.longitude - minCoordinate.longitude
        let latitudeDelta = -(maxCoordinate.latitude - minCoordinate.latitude)
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
