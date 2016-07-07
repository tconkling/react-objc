Pod::Spec.new do |s|

  s.name         = "ReactObjC"
  s.version      = "0.5.1"
  s.summary      = "Signals, Reactive Values, Futures, and Promises for Objective-C"

  s.description  =
    "A port of Michael Bayne's React library for Java (https://github.com/threerings/react).
    Signals, slots, and functional-reactive programming for Objective-C."

  s.homepage     = "https://github.com/tconkling/react-objc"

  s.license      = { :type => "BSD", :file => "LICENSE" }


  s.author             = { "Tim Conkling" => "tim@timconkling.com" }
  s.social_media_url   = "https://twitter.com/timconkling"

  s.ios.deployment_target = "5.0"
  s.osx.deployment_target = '10.7'

  s.source       = { :git => "https://github.com/tconkling/react-objc.git", :tag => "#{s.version}" }

  s.source_files  = "react/**/*.{h,m}"

end
