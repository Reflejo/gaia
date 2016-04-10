import CoreLocation

/**
 This protocol serves as delegation for when any mutable property on a marker changes. Map providers will 
 have to react in order to reflect these properties (animated when posible).
 */
protocol MapMarkerDelegate: class {

    /**
     This method is called when the rotation property on the marker was changed.

     - parameter marker:   The underlying marker that was mutated.
     - parameter rotation: The new rotation value.
     */
    func markerRotationDidChange(marker: MapProviderAnnotation, rotation: CLLocationDegrees)

    /**
     This method is called when the position property on the marker was changed.

     - parameter marker:   The underlying marker that was mutated.
     - parameter position: The new earth coordinate.
     */
    func markerPositionDidChange(marker: MapProviderAnnotation, position: CLLocationCoordinate2D)

    /**
     This method is called when the tappable property on the marker was changed.

     - parameter marker:   The underlying marker that was mutated.
     - parameter tappable: The new boolean indicating if the marker can be tappable or not.
     */
    func markerTappableDidChange(marker: MapProviderAnnotation, tappable: Bool)

    /**
     This method is called when the opacity property on the marker was changed.

     - parameter marker:  The underlying marker that was mutated.
     - parameter opacity: The new opacity of the marker.
     */
    func markerOpacityDidChange(marker: MapProviderAnnotation, opacity: Float)
}
