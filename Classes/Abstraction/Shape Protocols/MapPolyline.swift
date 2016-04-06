/**
 `MapPolyline` specifies the available options for a polyline that exists on the Earth's surface.
 It is drawn as a physical line between the points specified in |path|.
 */
public protocol MapPolyline: MapShape {

    /// The UIColor used to render the polyline.
    var strokeColor: UIColor { get set }

    /// The width of the line in screen points.
    var strokeWidth: CGFloat { get set }

    /**
     The polyline drawn as a physical line between the points specified in `path`.

     - parameter path: The `MapPath` from where the polyline will be drawn.

     - returns: the newly created MapPolyline connecting the points in `path`.
     */
    static func fromPath(path: MapPath) -> MapPolyline
}
