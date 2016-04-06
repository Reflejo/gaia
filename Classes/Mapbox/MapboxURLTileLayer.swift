// FIXME: Support map tiles on Mapbox
final class MapboxURLTileLayer: MapURLTileLayer {

    var opacity: Float {
        get { return 1.0 }
        set { }
    }

    var zIndex: Int32 = 0

    func clearTileCache() {}

    static func withURLConstructor(constructor: (x: UInt, y: UInt, zoom: UInt) -> NSURL?) -> MapURLTileLayer {
        assertionFailure("URLTileLayer not implemented on Mapbox yet")
        return MapboxURLTileLayer()
    }
}