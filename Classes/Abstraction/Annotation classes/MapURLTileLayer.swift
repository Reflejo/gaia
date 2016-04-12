/**
 `MapURLTileLayer` fetches tiles based on the URLs returned from the constructor every time the shown
  tiles are invalidated.
 */
public class MapURLTileLayer: MapAnnotation {

    public weak var underlyingAnnotation: MapProviderAnnotation?

    /// The closure that will be used to construct the URL to request the tiles.
    let constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?

    /**
     Clears the cache so that all tiles will be requested again.
     */
    func clearTileCache() {}

    /**
     Creates an instance of `MapURLTileLayer` which will fetch the tiles using the URL created by the given
     closure.

     - parameter constructor: A closure that, given (x, y, zoom) will return a valid URL to request.

     - returns: the newly created `MapURLTileLayer` ready to fetch tiles from the URL constructed by the
                given closure.
     */
    init(constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?) {
        self.constructor = constructor
    }
}
