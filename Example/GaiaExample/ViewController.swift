import UIKit

class ViewController: UIViewController {

    @IBAction private func drawPolygon() {
        let viewControllers = self.childViewControllers.flatMap { $0 as? MapViewController }
        viewControllers.forEach { $0.drawPolygon() }
    }

    @IBAction private func drawPolylineAndMoveCar() {
        let viewControllers = self.childViewControllers.flatMap { $0 as? MapViewController }
        viewControllers.forEach { $0.drawPolylineAndMoveCar() }
    }

    @IBAction private func zoomMap() {
        let viewControllers = self.childViewControllers.flatMap { $0 as? MapViewController }
        viewControllers.forEach { $0.zoom() }
    }
}
