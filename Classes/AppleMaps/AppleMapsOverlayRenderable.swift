import MapKit

/**
 An apple maps overlay renderable should be capable of cereating a renderer to render itself.
 */
protocol AppleMapsOverlayRenderable {

    /// A renderer capable of render the shape using the meta type to set the needed properties.
    var overlayRenderer: MKOverlayPathRenderer { get }
}

final class AppleMapsPolyline: MKPolyline, AppleMapsOverlayRenderable {

    /// The meta polyline associated to the shape containing properties such as strokeWidth, color, etc
    var metaPolyline: MapPolyline?

    var overlayRenderer: MKOverlayPathRenderer {
        let renderer = MKPolylineRenderer(overlay: self)
        renderer.lineWidth = self.metaPolyline?.strokeWidth ?? 1.0
        renderer.strokeColor = self.metaPolyline?.strokeColor
        return renderer
    }
}

final class AppleMapsPolygon: MKPolygon, AppleMapsOverlayRenderable {

    /// The meta polygon associated to the shape containing properties such as strokeWidth, color, etc
    var metaPolygon: MapPolygon?

    var overlayRenderer: MKOverlayPathRenderer {
        let renderer = MKPolygonRenderer(overlay: self)
        renderer.lineWidth = self.metaPolygon?.strokeWidth ?? 1.0
        renderer.strokeColor = self.metaPolygon?.strokeColor
        renderer.fillColor = self.metaPolygon?.fillColor
        return renderer
    }
}

final class AppleMapsCircle: MKCircle, AppleMapsOverlayRenderable {

    /// The meta polygon associated to the shape containing properties such as radius, strokeWidth, color, etc
    var metaCircle: MapCircle?

    var overlayRenderer: MKOverlayPathRenderer {
        let renderer = MKCircleRenderer(overlay: self)
        renderer.lineWidth = self.metaCircle?.strokeWidth ?? 1.0
        renderer.strokeColor = self.metaCircle?.strokeColor
        renderer.fillColor = self.metaCircle?.fillColor
        return renderer
    }
}

extension MKPolygon: MapProviderAnnotation {}
extension MKPolyline: MapProviderAnnotation {}
extension MKCircle: MapProviderAnnotation {}
