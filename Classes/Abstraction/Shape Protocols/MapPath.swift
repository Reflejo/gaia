import CoreLocation

private enum DecodingError: ErrorType {
    case InvalidPosition
    case InvalidNumberOfComponents
}

/**
 MapPath encapsulates an immutable array of CLLocationCooordinate2D.
 */
public struct MapPath {

    /// An array containing all the waypoints (i.e. GPS positions) on the path
    public var coordinates: [CLLocationCoordinate2D]

    /**
     Creates the path that contains all the given sets of points.

     - parameter points: The array of points that will be contained in the path.

     - returns: the newly created `MapPath` from the set of points.
     */
    public init(points: [CLLocationCoordinate2D]) {
        self.coordinates = points
    }

    /**
     Creates the path by extracting the points from the given encoded path.

     - parameter encodedPath: The encoded path using Google's Encoded Polyline Algorithm Format.

     - returns: the newly created `MapPath`.
     */
    public init?(encodedPath: String) {
        guard let coordinates = MapPath.decodePoints(encodedPath) else {
            return nil
        }

        self.coordinates = coordinates
    }

    /**
     Decodes a string encoded using Google Polyline Encoding Format into an array of coordinates

     - parameter encoded: The string encoded using Google Polyline Encoding Format

     - returns: an array of locations or nil if the encoded path is invalid
     */
    static func decodePoints(encoded: String) -> [CLLocationCoordinate2D]? {
        let bytes = Array(encoded.utf8)
        var position = 0

        var coordinates = [CLLocationCoordinate2D]()

        var latitude = 0.0
        var longitude = 0.0

        let length = bytes.count
        while position < bytes.count {
            do {
                latitude += try MapPath.decodeCoordinate(bytes: bytes, length: length, position: &position)
                longitude += try MapPath.decodeCoordinate(bytes: bytes, length: length, position: &position)
            } catch {
                return nil
            }

            coordinates.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }

        return coordinates
    }

    // MARK: - Private helpers

    private static func decodeCoordinate(bytes bytes: [UInt8], length: Int, inout position: Int)
        throws -> Double
    {
        guard position < length else {
            throw DecodingError.InvalidPosition
        }

        var char: UInt8
        var numberOfComponents = 0
        var coordinate = 0
        repeat {
            char = bytes[position] - 63
            coordinate |= Int(char & 0x1F) << (5 * numberOfComponents)
            position += 1
            numberOfComponents += 1
        } while (char & 0x20) == 0x20 && position < length && numberOfComponents < 6

        if numberOfComponents == 6 && (char & 0x20) == 0x20 {
            throw DecodingError.InvalidNumberOfComponents
        }

        if (coordinate & 0x01) == 0x01 {
            coordinate = ~(coordinate >> 1)
        } else {
            coordinate = coordinate >> 1
        }
        
        return Double(coordinate) / 1e5
    }
}
