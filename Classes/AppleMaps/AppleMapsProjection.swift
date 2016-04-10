import MapKit

struct AppleMapsProjection {
    private weak var map: MKMapView?

    /**
     Creates a projection for a given map view. Note that the mapview is a reference for the AppleMaps case,
     and so the projection is not "frozen" when instantiated.

     - parameter mapboxView: The reference of the map view.
     */
    init(map: MKMapView) {
        self.map = map
    }
}

extension AppleMapsProjection: MapProjection {

    func pointForCoordinate(coordinate: CLLocationCoordinate2D) -> CGPoint {
        guard let mapView = self.map else {
            return .zero
        }

        return mapView.convertCoordinate(coordinate, toPointToView: mapView)
    }

    func pointsForMeters(meters: CLLocationDistance, atCoordinate coordinate: CLLocationCoordinate2D)
        -> CGFloat
    {
        guard let mapView = self.map else {
            return 0.0
        }

        let oneMeterRegion = MKCoordinateRegionMakeWithDistance(coordinate, meters, 0.0)
        let rect = mapView.convertRegion(oneMeterRegion, toRectToView: nil)
        return rect.height
    }
}
