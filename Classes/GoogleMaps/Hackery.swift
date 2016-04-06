import GoogleMaps

extension GMSMapView {

    /// A boolean that indicates if the map reports to be in the middle of an animation.
    var isAnimating: Bool {
        // Don't ask me why the name is "reportIdle" when is the exact opposite. Google ¯\_(ツ)_/¯ amirite?
        return self.valueForKey("_maskReportIdle") as? Bool == true
    }

    /// A boolean that indicates if the map is being move using a gesture recognizer.
    var duringGesture: Bool {
        let duringGesture = self.valueForKey("_duringGesture") as? Bool
        return duringGesture == true
    }

    /// Number of touches on the screen for the running gesture.
    var touchesInScreen: Int {
        return self.gestureRecognizers?.first?.numberOfTouches() ?? 0
    }

    /// Returns the view associated with the little google logo image/button
    var attributionButton: UIView? {
        let settings = self.valueForKey("_settings") as? NSObject
        let settingsView = settings?.valueForKey("view") as? UIView

        return settingsView?.subviews.last as? UIButton
    }

    /**
    Switches to navigation mode. This mode shows the streets labels bigger and replaces the blue dot for a
    navigation icon that follows the user's heading.

    - parameter navigating: A boolean indicating if navigation mode should be enabled (true) or disabled
                            (false).
    */
    func setNavigating(navigating: Bool) {
        let vectorMap = self.valueForKey("mapView") as? NSObject
        let selectorString = "setNavigating:"
        vectorMap?.performSelector(Selector(selectorString), withObject: navigating ? 1 : nil,
                                   withObject: nil)
    }
}
