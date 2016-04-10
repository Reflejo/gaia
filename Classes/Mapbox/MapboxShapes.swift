import Mapbox

final class MapboxPolyline: MGLPolyline {

    /// The meta polyline associated to the shape containing properties such as strokeWidth, color, etc
    var metaPolyline: MapPolyline?
}

final class MapboxPolygon: MGLPolygon {

    /// The meta polygon associated to the shape containing properties such as strokeWidth, color, etc
    var metaPolygon: MapPolygon?
}

//final class MapboxCircle: MGLCircle {
//
//    /// The meta polygon associated to the shape containing properties such as radius, strokeWidth, color, etc
//    var metaCircle: MapCircle?
//}

extension MGLPolygon: MapProviderAnnotation {}
extension MGLPolyline: MapProviderAnnotation {}
