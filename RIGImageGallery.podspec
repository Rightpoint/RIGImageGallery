Pod::Spec.new do |s|
  s.name             = "RIGImageGallery"
  s.version          = "0.1.0"
  s.summary          = "An image gallery view controller designed to work with the Raizlabs Interface Guidelines for iOS."

  s.description      = <<-DESC
                        An image gallery view controller designed to work with the Raizlabs Interface Guidelines for iOS.

                        Includes pinch to zoom, swiping between images, and tap to hide scrollbars.
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
