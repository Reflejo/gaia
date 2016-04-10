import UIKit
import Gaia

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        Gaia.registerProvider(.GoogleMaps, APIKey: Constants.GoogleKey)
        Gaia.registerProvider(.Mapbox, APIKey: Constants.MapboxKey)
        Gaia.registerProvider(.AppleMaps)

        return true
    }
}
