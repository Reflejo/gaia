import Mapbox

extension MapboxMarker: MapProviderAnnotation {}

final class MapboxMarker: MGLPointAnnotation {
    /// The marker meta information such as image, opacity, etc.
    let metaMarker: MapMarker

    /**
     Creates an `AppleMapsMarker` by associating the given metaMarker.

     - parameter metaMarker: The metaMarker to associate on the newly created marker.
     */
    init(metaMarker: MapMarker) {
        self.metaMarker = metaMarker
        super.init()

        self.coordinate = metaMarker.position
        metaMarker.underlyingAnnotation = self
    }
}
