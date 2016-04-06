import GoogleMaps

extension GMSCameraUpdate: MapCameraUpdate {

    public static func withTarget(target: CLLocationCoordinate2D) -> MapCameraUpdate {
        return GMSCameraUpdate.setTarget(target)
    }

    public static func withTarget(target: CLLocationCoordinate2D, zoom: Float) -> MapCameraUpdate {
        return GMSCameraUpdate.setTarget(target, zoom: zoom)
    }

    public static func fitBounds(bounds: CoordinateBounds) -> MapCameraUpdate {
        let bounds = GMSCoordinateBounds(coordinate: bounds.northEast, coordinate: bounds.southWest)
        return GMSCameraUpdate.fitBounds(bounds)
    }
}
