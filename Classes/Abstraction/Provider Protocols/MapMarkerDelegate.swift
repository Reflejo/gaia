import CoreLocation

/**
 This protocol serves as delegation for when any mutable property on a marker changes. Map providers will
 have to react in order to reflect these properties (animated when posible).
 */
protocol MapMarkerDelegate: class {

    /**
     Animate changes to one or more properties using the specified duration, delay, options, and completion
     handler.

     - parameter marker:     The underlying marker that was mutated.
     - parameter duration:   The total duration of the animations, measured in seconds.
     - parameter options:    A mask of options indicating how you want to perform the animations.
     - parameter animations: A closure containing the changes to commit to the marker. This is where you
                             programmatically change any animatable properties of the marker. Always use the
                             marker given as the closure's first argument.
     - parameter completion: A closure to be executed when the animation sequence ends.
     */
    func animate(marker: MapProviderAnnotation, duration: NSTimeInterval, options: UIViewAnimationOptions,
                 animations: () -> Void, completion: (Bool -> Void)?)

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
