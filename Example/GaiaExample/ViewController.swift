import CoreLocation
import Gaia
import UIKit

private let kStartPoint = CLLocationCoordinate2D(latitude: 37.775598, longitude: -122.418049)
private let kEndPoint = CLLocationCoordinate2D(latitude: 37.760442, longitude: -122.413316)

class ViewController: UIViewController {

    @IBAction private func drawPolygon() {
        let viewControllers = self.childViewControllers.flatMap { $0 as? MapViewController }
        viewControllers.forEach { $0.drawPolygon() }
    }

    @IBAction private func drawPolylineAndMoveCar() {
        for case let viewController as MapViewController in self.childViewControllers {
            let API = MapAPI(provider: viewController.mapView.provider)

            viewController.HUD.show("Getting directions")
            API.directions(wayPoints: [kStartPoint, kEndPoint], profile: .Driving) { response in
                viewController.HUD.hide()
                guard case .Success(let legs, _) = response else {
                    return
                }

                let overview = MapPolyline(coordinates: legs.flatMap { $0 }, strokeColor: .magentaColor(),
                                           strokeWidth: 5.0)
                viewController.drawPolylineAndMoveCar(from: kStartPoint, to: kEndPoint, route: overview)
            }
        }
    }

    @IBAction private func zoomMap() {
        let viewControllers = self.childViewControllers.flatMap { $0 as? MapViewController }
        viewControllers.forEach { $0.zoom(to: kEndPoint, zoom: 15) }
    }

    @IBAction private func reverseGeocode() {
        for case let viewController as MapViewController in self.childViewControllers {
            let API = MapAPI(provider: viewController.mapView.provider)

            viewController.HUD.show("Reverse geocoding")
            API.reverseGeocode(coordinate: viewController.mapView.centerPosition) { response in
                viewController.HUD.hide()
                guard case .Success(let places) = response else {
                    return
                }

                viewController.setAddress(places.first?.formattedAddress)
            }
        }
    }
}
