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

class MapViewController: UIViewController {

    @IBOutlet private var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.setPadding(UIEdgeInsets(top: 30.0, left: 0.0, bottom: 30.0, right: 0.0), animated: false)
    }

    func zoom() {
        self.mapView.animateToTarget(Constants.TestStartPoint, zoom: 15)
    }

    func drawPolylineAndMoveCar() {
        self.mapView.clear()

        let markerStart = MapMarker(position: Constants.TestStartPoint)
        let markerEnd = MapMarker(position: Constants.TestEndPoint)
        self.mapView.addMarker(markerStart)
        self.mapView.addMarker(markerEnd)

        let route = MapPolyline(encodedPath: Constants.TestEncodedRoute, strokeColor: .magentaColor(),
                                strokeWidth: 5.0)!
        self.mapView.addShape(route)

        self.mapView.zoomToRegion(thatFitsCoordinates: [Constants.TestStartPoint, Constants.TestEndPoint])
        self.makeCarDrive(throughCoordinates: route.coordinates)
    }

    func drawPolygon() {
        self.mapView.clear()

        let lightMagenta = UIColor.magentaColor().colorWithAlphaComponent(0.3)
        let polygon = MapPolygon(encodedPath: Constants.TestEncodedPolygon, strokeWidth: 1.0,
                                 strokeColor: .magentaColor(), fillColor: lightMagenta)
        if let polygon = polygon {
            self.mapView.addShape(polygon)
            self.mapView.zoomToRegion(thatFitsBounds: polygon.bounds)
        }
    }

    private func makeCarDrive(throughCoordinates coordinates: [CLLocationCoordinate2D]) {
        let carMarker = MapMarker(position: coordinates[0], icon: UIImage(named: "lyft_black"))
        carMarker.rotation = MapUtils.heading(from: coordinates[0], to: coordinates[1])
        self.mapView.addMarker(carMarker)

        let stepDuration = 0.8
        for (i, coordinate) in coordinates.enumerate() {
            executeAfter(Double(i) * stepDuration) {
                CATransaction.begin()
                CATransaction.setAnimationDuration(stepDuration)
                carMarker.position = coordinate
                if i > 0 {
                    carMarker.rotation = MapUtils.heading(from: coordinates[i - 1], to: coordinates[i])
                }
                CATransaction.commit()
            }
        }

        executeAfter(Double(coordinates.count) * stepDuration) {
            self.mapView.removeAnnotation(carMarker, animated: true)
        }
    }
}
