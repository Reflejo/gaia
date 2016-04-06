import UIKit
import Gaia

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        Gaia.SDK = .Mapbox
        Gaia.provideAPIKey("", forProvider: .GoogleMaps)
        Gaia.provideAPIKey("..", forProvider: .Mapbox)

        return true
    }
}
