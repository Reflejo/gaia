import CoreLocation
import Gaia
import UIKit

/**
 Executes the given clousure after a delay of "delay" seconds.

 - parameter delay:   The delay in seconds.
 - parameter closure: A closure that is going to be executed after the delay.
 */
public func executeAfter(delay: Double, closure: () -> Void) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), closure)
}

private let kEncodedRoute = "m~peFjydjVnGsI`DiEvDiF~B_DrD_FRXv@z@t@h@v@^jAXl@Ff@?lDS~DQhFSxQw@~FY`EQF`C"
private let kStartPoint = CLLocationCoordinate2D(latitude: 37.775598, longitude: -122.418049)
private let kEndPoint = CLLocationCoordinate2D(latitude: 37.760442, longitude: -122.413316)

class ViewController: UIViewController {

    @IBOutlet private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.setPadding(UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0), animated: false)

        executeAfter(1.0) {
            self.mapView.animateToTarget(kStartPoint, zoom: 10)
        }
    }

    @IBAction private func drawPolygon() {
        self.mapView.clear()

        let markerStart = Gaia.createMarker(atPosition: kStartPoint)
        let markerEnd = Gaia.createMarker(atPosition: kEndPoint)
        self.mapView.addShape(markerStart)
        self.mapView.addShape(markerEnd)

        let path = MapPath(encodedPath: kEncodedRoute)!
        let route = Gaia.createPolyline(withPath: path, strokeColor: .magentaColor(), strokeWidth: 5.0)
        self.mapView.addShape(route)

        self.mapView.zoomToRegion(thatFitsCoordinates: [kStartPoint, kEndPoint])
        self.makeCarDrive(throughCoordinates: path.coordinates)
    }

    private func makeCarDrive(throughCoordinates coordinates: [CLLocationCoordinate2D]) {
        let carMarker = Gaia.createMarker(atPosition: coordinates[0])
        carMarker.icon = UIImage(named: "lyft_black")
        carMarker.rotation = Gaia.Utils.heading(from: coordinates[0], to: coordinates[1])
        carMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        self.mapView.addShape(carMarker)

        for (i, coordinate) in coordinates.enumerate() {
            executeAfter(Double(i) * 1) {
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                carMarker.position = coordinate
                if i > 0 {
                    carMarker.rotation = Gaia.Utils.heading(from: coordinates[i - 1], to: coordinates[i])
                }
                CATransaction.commit()
            }
        }
    }
}
