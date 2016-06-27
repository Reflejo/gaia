Pod::Spec.new do |s|
  s.name                = "Gaia"
  s.version             = "0.0.1"
  s.summary             = "Gaia provides a unified interface to interact with map SDKs in iOS."
  s.homepage            = "https://github.com/lyft/gaia"
  s.license             = "MIT"
  s.author              = { "Martin Conte Mac Donell" => "Reflejo@gmail.com" }
  s.platform            = :ios, "8.0"
  s.source              = { :git => "git@github.com:lyft/gaia.git" }
  s.default_subspec     = "Core"

  s.subspec 'Core' do |ss|
    ss.dependency     "Gaia/GoogleMaps"
    ss.dependency     "Gaia/Mapbox"
    ss.dependency     "Gaia/AppleMaps"
  end

  # Workaround while this is fixed: https://code.google.com/p/gmaps-api-issues/issues/detail?id=9512
  s.subspec 'GoogleMapsFramework' do |ss|
    ss.frameworks          = [
        "Accelerate", "AVFoundation", "CoreBluetooth", "CoreData",
        "CoreLocation", "CoreText", "GLKit", "ImageIO", "OpenGLES",
        "QuartzCore", "Security", "SystemConfiguration", "CoreGraphics"
    ]
    ss.libraries           = "icucore", "c++", "z"
    ss.vendored_frameworks = "Frameworks/GoogleMaps.framework"
    ss.xcconfig            = { 'FRAMEWORK_SEARCH_PATHS' => '"../Frameworks/"' }
    ss.resources           = "Frameworks/GoogleMaps.framework/Versions/A/Resources/GoogleMaps.bundle"
  end

  s.subspec 'GoogleMaps' do |ss|
    ss.dependency     "Gaia/Abstraction"
    ss.dependency     "Gaia/GoogleMapsFramework"

    ss.source_files        = "Classes/GoogleMaps/*.swift"
  end

  s.subspec 'Mapbox' do |ss|
    ss.dependency     "Gaia/Abstraction"
    ss.dependency     "Alamofire"
    ss.dependency     "Mapbox-iOS-SDK"

    ss.source_files        = "Classes/Mapbox/*.swift"
  end

  s.subspec 'AppleMaps' do |ss|
    ss.dependency     "Gaia/Abstraction"

    ss.source_files        = "Classes/AppleMaps/*.swift"
  end

  s.subspec 'Abstraction' do |ss|
    ss.source_files   = "Classes/Abstraction/**/*.swift"
  end
end
