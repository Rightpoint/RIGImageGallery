Pod::Spec.new do |s|
  s.name             = "RIGImageGallery"
  s.version          = "0.0.1"
  s.summary          = "An image gallery view controller designed to work with the Raizlabs Interface Guidelines for iOS."

  s.description      = <<-DESC
                        An image gallery view controller designed to work with the Raizlabs Interface Guidelines for iOS.

                        Includes pinch to zoom, swiping between images, and tap to hide scrollbars.
                       DESC

  s.homepage         = "https://github.com/raizlabs/RIGImageGallery"
  s.license          = 'MIT'
  s.author           = { "Michael Skiba" => "mike.skiba@raizlabs.com" }
  s.source           = { :git => "https://github.com/raizlabs/RIGImageGallery.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'RIGImageGallery', 'RIGImageGallery/**/*'

  s.frameworks   = ["Foundation", "UIKit"]

end
