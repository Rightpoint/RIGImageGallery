# RIGImageGallery
> An image gallery for iOS

[![Build Status](https://travis-ci.org/Raizlabs/RIGImageGallery.svg?branch=develop)](https://travis-ci.org/Raizlabs/RIGImageGallery)
[![Version](https://img.shields.io/cocoapods/v/RIGImageGallery.svg?style=flat)](http://cocoapods.org/pods/RIGImageGallery)
[![License](https://img.shields.io/cocoapods/l/RIGImageGallery.svg?style=flat)](http://cocoapods.org/pods/RIGImageGallery)
[![Platform](https://img.shields.io/cocoapods/p/RIGImageGallery.svg?style=flat)](http://cocoapods.org/pods/RIGImageGallery)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

RIGImageGallery is a photo gallery meant to provide most of the functionality of the image gallery in the system Photos app, and handle asynchronous loading of images.

This library is part of the Raizlabs Interface Guidelines, which are  UI components that offer sensible defaults to help a project get off the ground quickly with components that feel native to the platform, and with easy to use customization options.

![RIGImageGallery](Resources/rig_demo.gif)

## Features

- [x] Swipe to advance
- [x] Pinch to zoom
- [x] Double tap to toggle 1:1 zoom
- [x] Single tap to hide the nav bar

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation with CocoaPods

#### CocoaPods
RIGImageGallery is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'RIGImageGallery'
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#if-youre-building-for-ios) to add `$(SRCROOT)/Carthage/Build/iOS/RIGImageGallery.framework` to an iOS project.

```ogdl
github "Raizlabs/RIGImageGallery"
```

#### Manually
1. Download all of the `.swift` files in `RIGImageGallery/` and drop them into your project.  
2. Congratulations!  

## Usage example

To see a complete example of using the gallery, take a look at the [sample project](https://github.com/Raizlabs/RIGImageGallery/blob/develop/RIGImageGalleryDemo/View%20Controller/ViewController.swift).

### Creating a Gallery from Image URLs

```swift
func createPhotoGallery() -> RIGImageGalleryViewController {

    let urls: [URL] = [
          "https://placehold.it/1920x1080",
          "https://placehold.it/1080x1920",
          "https://placehold.it/350x150",
          "https://placehold.it/150x350",
        ].flatMap(URL.init(string:))

    let rigItems: [RIGImageGalleryItem] = urls.map { _ in
        RIGImageGalleryItem(placeholderImage: UIImage(named: "placeholder") ?? UIImage(),
                            isLoading: true)
    }

    let rigController = RIGImageGalleryViewController(images: rigItems)

    for (index, URL) in urls.enumerated() {
        let request = imageSession.dataTask(with: URLRequest(url: URL)) { [weak rigController] data, _, error in
            if let image = data.flatMap(UIImage.init), error == nil {
                rigController?.images[index].image = image
                rigController?.images[index].isLoading = false
            }
        }
        request.resume()
    }

    return rigController
}
```

### Presenting and Customizing the View Controller
```swift
@objc func showGallery(_ sender: UIButton) {
    let photoViewController = createPhotoGallery()
    photoViewController.dismissHandler = dismissPhotoViewer
    photoViewController.actionButtonHandler = actionButtonHandler
    photoViewController.actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
    photoViewController.traitCollectionChangeHandler = traitCollectionChangeHandler
    photoViewController.countUpdateHandler = updateCount
    let navigationController = UINavigationController(rootViewController: photoViewController)
    present(navigationController, animated: true, completion: nil)
}

func dismissPhotoViewer(_ :RIGImageGalleryViewController) {
    dismiss(animated: true, completion: nil)
}

func actionButtonHandler(_: RIGImageGalleryViewController, galleryItem: RIGImageGalleryItem) {
}

func updateCount(_ gallery: RIGImageGalleryViewController, position: Int, total: Int) {
    gallery.countLabel.text = "\(position + 1) of \(total)"
}

func traitCollectionChangeHandler(_ photoView: RIGImageGalleryViewController) {
    let isPhone = UITraitCollection(userInterfaceIdiom: .phone)
    let isCompact = UITraitCollection(verticalSizeClass: .compact)
    let allTraits = UITraitCollection(traitsFrom: [isPhone, isCompact])
    photoView.doneButton = photoView.traitCollection.containsTraits(in: allTraits) ? nil : UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
}
```

## Contributing

Issues and pull requests are welcome! Please ensure that you have the latest [SwiftLint](https://github.com/realm/SwiftLint) installed before committing and that there are no style warnings generated when building.

Contributors are expected to abide by the [Contributor Covenant Code of Conduct](https://github.com/Raizlabs/RIGImageGallery/blob/develop/CONTRIBUTING.md).

## License

RIGImageGallery is available under the MIT license. See the LICENSE file for more info.

## Author

Michael Skiba, <mailto:mike.skiba@raizlabs.com> [@atelierclkwrk](https://twitter.com/atelierclkwrk)
