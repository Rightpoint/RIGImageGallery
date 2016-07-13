//
//  ViewController.swift
//  RigPhotoViewerDemo
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import RIGImageGallery

class ViewController: UIViewController {

    let imageSession = NSURLSession(configuration: .defaultSessionConfiguration())

    @IBAction func showGallery(sender: UIButton) {
        let photoViewController = RIGImageGalleryViewController()
        photoViewController.photoViewDelegate = self
        loadImages(photoViewController)
        let navigationController = navBarWrappedViewController(photoViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }

    @IBAction func showSingle(sender: UIButton) {
    }

    private func navBarWrappedViewController(viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barStyle = .BlackTranslucent
        navigationController.navigationBar.tintColor = .whiteColor()
        navigationController.toolbar.barStyle = .BlackTranslucent
        navigationController.toolbar.tintColor = .whiteColor()
        return navigationController
    }
}

extension ViewController: RIGPhotoViewControllerDelegate {

    func dismissPhotoViewer() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func actionForGalleryItem(galleryItem: RIGImageGalleryItem) {
    }

    func showDismissForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        let isPhone = UITraitCollection(userInterfaceIdiom: .Phone)
        let isCompact = UITraitCollection(verticalSizeClass: .Compact)
        let allTraits = UITraitCollection(traitsFromCollections: [isPhone, isCompact])
        return !traitCollection.containsTraitsInCollection(allTraits)
    }

}

private extension ViewController {

    static let urls: [NSURL] = [
        NSURL(string: "https://placehold.it/1920x1080"),
        NSURL(string: "https://placehold.it/1080x1920"),
        NSURL(string: "https://placehold.it/350x150"),
        NSURL(string: "https://placehold.it/150x350"),
        ].flatMap { $0 }

    func loadImages(rigController: RIGImageGalleryViewController) {
        let emptyItem = RIGImageGalleryItem(placeholderImage: UIImage(named: "placeholder"))

        let imagesAndRequests: [(image: RIGImageGalleryItem, task: NSURLSessionTask)] = self.dynamicType.urls.enumerate().map { (index, URL) in
            let completion = rigController.handleImageLoadAtIndex(index)
            let request = imageSession.dataTaskWithRequest(NSURLRequest(URL: URL), completionHandler: completion)
            return (image: emptyItem, task: request)
        }

        rigController.images = imagesAndRequests.map({ $0.image })
        imagesAndRequests.forEach({ $0.task.resume() })
        rigController.setCurrentImage(1, animated: false)
    }
}

private extension RIGImageGalleryViewController {
    func handleImageLoadAtIndex(index: Int) -> ((NSData?, NSURLResponse?, NSError?) -> ()) {
        return { [weak self] (data: NSData?, response: NSURLResponse?, error: NSError?) in
            guard let image = data.flatMap(UIImage.init) where error == nil else {
                print(error)
                return
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if let currentImage = self?.images[index] {
                    self?.images[index] = currentImage.updateImage(image)
                }
            }
        }
    }
}
