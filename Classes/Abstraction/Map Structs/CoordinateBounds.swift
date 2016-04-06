import CoreLocation

/**
 This struct represents a rectangular bounding box on the Earth's surface. Note that properties are immutable
 and can't be modified after construction.

 WARNING: We are using some Google Maps functions here for the math but this abstraction is used on all SDKs.
 */
public struct CoordinateBounds {

    /// The North-East corner of these bounds.
    public let northEast: CLLocationCoordinate2D

    /// The South-West corner of these bounds.
    public let southWest: CLLocationCoordinate2D

    /// The center position of the bounds.
    public var center: CLLocationCoordinate2D {
        return Gaia.Utils.interpolate(from: self.northEast, to: self.southWest, fraction: 0.5)
    }

    /**
     Creates a CoordinateBounds containing every point included in the passed-in array.

     - parameter coordinates: An array of coordinates from which the bounds will be calculated
     */
    public init(includingCoordinates coordinates: [CLLocationCoordinate2D]) {
        let edges = Gaia.Utils.boundsEdges(fromCoordinates: coordinates)
        self.northEast = edges.northEast
        self.southWest = edges.southWest
    }

    /**
     Creates a CoordinateBounds containing every point on the given shape paths.

     - parameter shapes: An array of shapes from which the bounds will be calculated
     */
    public init?(shapes: [MapShape]) {
        guard let firstBound = shapes.first?.bounds else {
            return nil
        }

        let bounds = shapes[1 ..< shapes.count]
            .flatMap { $0.bounds }
            .reduce(firstBound) { $0.includingBounds($1) }

        self.northEast = bounds.northEast
        self.southWest = bounds.southWest
    }

    /**
     Inits the northEast and southWest bounds corresponding to the rectangular region defined by the two
     corners.

     It is ambiguous whether the longitude of the box extends from |coord1| to |coord2| or vice-versa,
     the box is constructed as the smaller of the two variants, eliminating the ambiguity.

     - parameter coordinate1: One of the two corners of the box
     - parameter coordinate2: The other corners of the box
     */
    public init(coordinate coord1: CLLocationCoordinate2D, coordinate coord2: CLLocationCoordinate2D) {
        let edges = Gaia.Utils.boundsEdges(fromCoordinates: [coord1, coord2])

        self.northEast = edges.northEast
        self.southWest = edges.southWest
    }

    /**
     Derives new coordinates that contain the bounds centered at the given center. This is done by creating a
     rect with all the locations and then projecting the distance D(NE corner, center) to a new point in the
     SW where D(SW, center) == D(NE, center).

     - parameter center: The desired center of the new bounds

     - returns: New bounds centered at the given coordinate
     */
    @warn_unused_result
    public func derive(center: CLLocationCoordinate2D) -> CoordinateBounds {
        let northEastIsFarther = center.distanceTo(self.northEast) > center.distanceTo(self.southWest)
        let farCoordinate = northEastIsFarther ? self.northEast : self.southWest
        let derivedCoordinate = Gaia.Utils.interpolate(from: farCoordinate, to: center, fraction: 2.0)

        return CoordinateBounds(coordinate: farCoordinate, coordinate: derivedCoordinate)
    }

    /**
     Moves bounds to be centered around new center, without adjusting zoom level

     - parameter center: The desired center of the new bounds

     - returns: New bounds centered at the given coordinate
     */
    @warn_unused_result
    public func translateTo(center: CLLocationCoordinate2D) -> CoordinateBounds {
        let boundsCenter = self.center
        let distance = boundsCenter.distanceTo(center)
        let angle = Gaia.Utils.heading(from: boundsCenter, to: center)
        let northEast = Gaia.Utils.offset(from: self.northEast, distance: distance, heading: angle)
        let southWest = Gaia.Utils.offset(from: self.southWest, distance: distance, heading: angle)

        return CoordinateBounds(coordinate: northEast, coordinate: southWest)
    }

    /**
     Offsets the current bounds by the factor

     - parameter offsetFactor: The offset factor to apply to the current bounds

     - returns: New bounds offset by the given factor
     */
    @warn_unused_result
    public func extendSouthEast(offsetFactor offsetFactor: Double) -> CoordinateBounds {
        let northEast = self.northEast
        let southWest = self.southWest
        let northWest = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        let southEast = CLLocationCoordinate2D(latitude: southWest.latitude, longitude: northEast.longitude)

        let distance = northWest.distanceTo(southEast)
        let offsetSouthEast = Gaia.Utils.offset(from: southEast, distance: distance * offsetFactor,
                                                heading: CLLocationDirection(135))

        return CoordinateBounds(coordinate: northWest, coordinate: offsetSouthEast)
    }

    /**
     Restricts the bounds size to the given maximum and minimum distances (in meters, diagonally).

     - parameter min: The minimum distance (in meters, diagonally) that should be visible.
     - parameter max: The maximum distance (in meters, diagonally) that should be visible.

     - returns: the newly calculated bounds with a diagnoal distance not greater than max and not less
                than min.
     */
    @warn_unused_result
    public func boundToDistance(min min: CLLocationDistance, max: CLLocationDistance) -> CoordinateBounds {
        let visibleDistance = self.northEast.distanceTo(self.southWest)
        if visibleDistance >= min && visibleDistance <= max {
            return self
        }

        let boundedDistance = Swift.min(Swift.max(visibleDistance, min), max)
        let delta = (1.0 + boundedDistance / visibleDistance) / 2.0
        let newNorthEast = Gaia.Utils.interpolate(from: self.southWest, to: self.northEast, fraction: delta)
        let newSouthWest = Gaia.Utils.interpolate(from: self.northEast, to: self.southWest, fraction: delta)

        return CoordinateBounds(coordinate: newNorthEast, coordinate: newSouthWest)
    }

    /**
     Returns a CoordinateBounds representing the current bounds extended to include the entire other bounds.

     - parameter bounds: The bounds used to extend the receiver.

     - returns: the newly extended bounds.
     */
    @warn_unused_result
    public func includingBounds(bounds: CoordinateBounds) -> CoordinateBounds {
        let northEast = CLLocationCoordinate2D(
            latitude: max(bounds.northEast.latitude, self.northEast.latitude),
            longitude: max(bounds.northEast.longitude, self.northEast.longitude)
        )
        let southWest = CLLocationCoordinate2D(
            latitude: min(bounds.southWest.latitude, self.southWest.latitude),
            longitude: min(bounds.southWest.longitude, self.southWest.longitude)
        )

        return CoordinateBounds(coordinate: northEast, coordinate: southWest)
    }
}
