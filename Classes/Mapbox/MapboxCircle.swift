import CoreLocation

final class MapboxCircle: MapCircle {
    var zIndex: Int32 = 0
    var position: CLLocationCoordinate2D
    var radius: CLLocationDistance
    var strokeWidth: CGFloat = 1.0
    var strokeLineColor = UIColor.blackColor()

    init(position: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.position = position
        self.radius = radius
    }
}

extension MapboxCircle: MapOverlay {
}