Pod::Spec.new do |s|
  s.name             = "RIGImageGallery"
  s.version          = "0.1.0"
  s.summary          = "An image gallery view controller designed to work with the Raizlabs Interface Guidelines for iOS."

  s.description      = <<-DESC
    RIGImageGallery is an image gallery for iOS written in Swift with sensible
    defaults that takes care of most of the hard parts automatically and offers easy
    block based customization.
                       DESC

  s.homepage         = "https://github.com/raizlabs/RIGImageGallery"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Michael Skiba" => "mike.skiba@raizlabs.com" }
  s.source           = { :git => "https://github.com/raizlabs/RIGImageGallery.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ateliercw'

  s.ios.deployment_target = '9.0'

  s.source_files = 'RIGImageGallery', 'RIGImageGallery/**/*'

  s.frameworks   = 'Foundation', 'UIKit'

end
