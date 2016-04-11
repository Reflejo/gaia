![gaia](https://cloud.githubusercontent.com/assets/232113/14424114/3e0a9eac-ff94-11e5-81f8-d1c681336a73.png)

Gaia provides a unified interface to interact with map SDKs in iOS. You
can add a `MapView` into your storyboard and switch between any
supported map provider just by setting one property.

This is an example of Gaia running with three instances of MapView with
providers: `Mapbox`, `AppleMaps`, `GoogleMaps.`

![gaia](https://cloud.githubusercontent.com/assets/232113/14424112/3a454092-ff94-11e5-9f61-72722fec2982.gif)

## Usage

The only thing you need to do before using the map is registering the
providers:

```swift
Gaia.registerProvider(.GoogleMaps, APIKey: "<Your key>")
Gaia.registerProvider(.Mapbox, APIKey: "<Your key>")
Gaia.registerProvider(.AppleMaps)
```

Then, just drag and drop a view into your storyboard, set the class as
`MapView` and assign the provider property on Interface Builder to any
of the supported providers. Alternatively, you can create the `MapView`
programatically as follows:

```swift
let mapView = MapView(provider: .GoogleMaps)
self.view.addSubview(mapView)
```

... And now you interact with the `MapView` the same way regardless of
the underlying provider, for example you can create a polyline:

```swift
let encoded = "m~peFjydjVnGsI`DiEvDiF~B_DrD_FRXv@z@t@h@v@^jAXl@Ff@?lDS~DQhFSxQw@~FY`EQF`C"
let route = MapPolyline(encodedPath: encoded, strokeColor: .magentaColor(), strokeWidth: 5.0)!
self.mapView.addShape(route)

self.mapView.zoomToRegion(thatFitsBounds: route.bounds)
```

.. or a polygon:

```swift
let polygon = MapPolygon(encodedPath: encoded, fillColor: .magentaColor())!
self.mapView.addShape(polygon)
```

.. or zoom the map using a zoom level:

```swift
let center = CLLocationCoordinate2D(latitude: 37.760442, longitude: -122.413316)
self.mapView.animateToTarget(center, zoom: 15)
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa
projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build Gaia.

To integrate Gaia into your Xcode project using CocoaPods, specify it in
your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Gaia'

# You can also import only the map providers you want to use
# pod 'Gaia/GoogleMaps'
# pod 'Gaia/Mapbox'
# pod 'Gaia/AppleMaps'
```

Then, run the following command:

```bash
$ pod install
```
