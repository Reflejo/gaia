import CoreLocation
import Gaia
import UIKit

private let kTotalCarDuration = 150.0
private let kInitialMapPosition = CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4)

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

    /// This is the UIView containing the abstract methods and the underlying map view.
    @IBOutlet var mapView: MapView!
    @IBOutlet var HUD: LoadingHUD!

    @IBOutlet private var reverseLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.reverseLabel.alpha = 0.0
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.mapView.setTarget(kInitialMapPosition, zoom: 15, animated: false)
        self.mapView.setPadding(UIEdgeInsets(top: 30.0, left: 0.0, bottom: 30.0, right: 0.0), animated: false)
    }

    func zoom(to to: CLLocationCoordinate2D, zoom: Float) {
        self.mapView.setTarget(to, zoom: zoom)
    }

    func drawPolylineAndMoveCar(from from: CLLocationCoordinate2D, to: CLLocationCoordinate2D,
                                    route: MapPolyline)
    {
        self.mapView.clear()
        self.mapView.addMarker(MapMarker(position: from))
        self.mapView.addMarker(MapMarker(position: to))
        self.mapView.addShape(route)

        self.mapView.zoomToRegion(thatFitsCoordinates: [from, to])
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

    func setAddress(address: String?) {
        self.reverseLabel.text = address
        UIView.animateWithDuration(0.3) {
            self.reverseLabel.alpha = address == nil ? 0.0 : 1.0
        }
    }

    private func makeCarDrive(throughCoordinates coordinates: [CLLocationCoordinate2D]) {
        let carMarker = MapMarker(position: coordinates[0], icon: UIImage(named: "lyft_black"))
        carMarker.rotation = MapUtils.heading(from: coordinates[0], to: coordinates[1])
        self.mapView.addMarker(carMarker)

        let distances = (1 ..< coordinates.count).map { coordinates[$0].distanceTo(coordinates[$0 - 1]) }
        let totalDistance = distances.reduce(0.0) { $0 + $1 }
        let steps = distances.enumerate()
            .filter { $0.element > 0.01 }
            .map { ($0.element / totalDistance, coordinates[$0.index], coordinates[$0.index + 1]) }

        func playStep(step: Int) {
            if step >= steps.count {
                return self.mapView.removeAnnotation(carMarker, animated: true)
            }

            let (deltaTime, start, end) = steps[step]
            carMarker.animate(
                duration: kTotalCarDuration * deltaTime,
                animations: { marker in
                    marker.position = end
                    marker.rotation = MapUtils.heading(from: start, to: end)
                },
                completion: { _ in playStep(step + 1) })
        }

        playStep(0)
    }
}
