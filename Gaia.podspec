Pod::Spec.new do |s|
  s.name                = "Gaia"
  s.version             = "0.0.1"
  s.summary             = ""
  s.homepage            = ""
  s.license             = "MIT"
  s.author              = { "Martin Conte Mac Donell" => "Reflejo@gmail.com" }
  s.platform            = :ios, "8.0"
  s.source              = { :git => "git@github.com:lyft/LyftKit.git" }
  s.default_subspec     = "Core"

  s.subspec 'Core' do |ss|
    ss.dependency     "Gaia/GoogleMaps"
    ss.dependency     "Gaia/Abstraction"
  end

  s.subspec 'GoogleMaps' do |ss|
    ss.dependency     "Gaia/Abstraction"
    ss.dependency     "GoogleMaps"

    ss.source_files   = "Classes/GoogleMaps/*.swift"
  end

  s.subspec 'Abstraction' do |ss|
    ss.source_files   = "Classes/Abstraction/*.swift"
  end
end
