import MapKit

private let kDefaultMapZoom = 13.0

extension MapProviderIdentifier {
    public static let AppleMaps = MapProviderIdentifier(AppleMapsView.self)
}

final class AppleMapsView: MKMapView {

}

extension AppleMapsView: MapSDKProvider {

    static var types = MapProviderTypes(
        MarkerType: AppleMapsMarker.self,
        MapURLTileLayerType: MKTileOverlay.self,
        CircleType: MKCircle.self,
        PolylineType: MKPolyline.self,
        PolygonType: MKPolygon.self,
        UtilsType: AppleMapsUtils.self,

        customTypes: [:]
    )
}