/**
 `MapURLTileLayer` fetches tiles based on the URLs returned from the constructor every time the shown
  tiles are invalidated.
 */
public protocol MapURLTileLayer: MapShape {

    /**
     Clears the cache so that all tiles will be requested again.
     */
    func clearTileCache()

    /**
     Creates an instance of `MapURLTileLayer` which will fetch the tiles using the URL created by the given
     closure.

     - parameter constructor: A closure that, given (x, y, zoom) will return a valid URL to request.

     - returns: the newly created `MapURLTileLayer` ready to fetch tiles from the URL constructed by the
                given closure.
     */
    static func withURLConstructor(constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?) -> MapURLTileLayer
}
