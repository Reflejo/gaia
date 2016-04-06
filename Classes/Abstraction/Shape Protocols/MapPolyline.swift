/**
 `MapPolyline` specifies the available options for a polyline that exists on the Earth's surface.
 It is drawn as a physical line between the points specified in |path|.
 */
public protocol MapPolyline: MapOverlay {

    /**
     The polyline drawn as a physical line between the points specified in `path`.

     - parameter path: The `MapPath` from where the polyline will be drawn.

     - returns: the newly created MapPolyline connecting the points in `path`.
     */
    static func fromPath(path: MapPath) -> MapPolyline
}
