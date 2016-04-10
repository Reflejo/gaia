import GoogleMaps

final class GoogleMapsMarker: GMSMarker {
    /// The marker meta information such as image, opacity, etc.
    let metaMarker: MapMarker

    /**
     Creates an `GoogleMapsMarker` by associating the given metaMarker.

     - parameter metaMarker: The metaMarker to associate on the newly created marker.
     */
    init(metaMarker: MapMarker) {
        self.metaMarker = metaMarker
        super.init()

        self.position = metaMarker.position
        self.icon = metaMarker.icons?.normal
        self.groundAnchor = self.icon != nil ? metaMarker.groundAnchor : CGPoint(x: 0.5, y: 1.0)
        self.rotation = metaMarker.rotation
        self.tappable = metaMarker.tappable
        self.opacity = metaMarker.opacity
        metaMarker.underlyingAnnotation = self
    }
}
