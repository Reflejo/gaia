import Mapbox

struct MapboxProjection {
    private weak var map: MGLMapView?

    /**
     Creates a projection for a given map view. Note that the mapview is a reference for the Mapbox case, and
     so the projection is not "frozen" when instantiated.

     - parameter mapboxView: The reference of the map view.
     */
    init(map: MGLMapView) {
        self.map = map
    }
}

extension MapboxProjection: MapProjection {

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

        return 1.0 / CGFloat(mapView.metersPerPointAtLatitude(coordinate.latitude))
    }
}
