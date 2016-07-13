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

    private let imageSession = NSURLSession(configuration: .defaultSessionConfiguration())

    override func loadView() {
        view = UIView()
        view.backgroundColor = .whiteColor()
        navigationItem.title = NSLocalizedString("RIG Image Gallery", comment: "Main screen title")

        let galleryButton = UIButton(type: .System)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.addTarget(self, action: #selector(ViewController.showGallery(_:)), forControlEvents: .TouchUpInside)
        galleryButton.setTitle(NSLocalizedString("Show Gallery", comment: "Show gallery button title"), forState: .Normal)

        let stackView = UIStackView(arrangedSubviews: [galleryButton])
        stackView.alignment = .Center
        stackView.axis = .Vertical
        stackView.layoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        stackView.distribution = .Fill
        stackView.spacing = 10
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            stackView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            stackView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            stackView.bottomAnchor.constraintLessThanOrEqualToAnchor(bottomLayoutGuide.topAnchor),
            stackView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }

}

private extension ViewController {

    @objc func showGallery(sender: UIButton) {
        let photoViewController = loadImages()
        photoViewController.dismissHandler = dismissPhotoViewer
        photoViewController.actionButtonHandler = actionButtonHandler
        photoViewController.traitCollectionChangeHandler = traitCollectionChangeHandler
        photoViewController.countUpdateHandler = updateCount
        let navigationController = navBarWrappedViewController(photoViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }

}

private extension ViewController {

    func dismissPhotoViewer(_ :RIGImageGalleryViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func actionButtonHandler(galleryItem: RIGImageGalleryItem) {
    }

    func updateCount(gallery: RIGImageGalleryViewController, position: Int, total: Int) {
        gallery.countLabel.text = "\(position.successor()) of \(total)"
    }

    func traitCollectionChangeHandler(photoView: RIGImageGalleryViewController) {
        let isPhone = UITraitCollection(userInterfaceIdiom: .Phone)
        let isCompact = UITraitCollection(verticalSizeClass: .Compact)
        let allTraits = UITraitCollection(traitsFromCollections: [isPhone, isCompact])
        photoView.doneButton = photoView.traitCollection.containsTraitsInCollection(allTraits) ? nil : UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
    }

}

private extension ViewController {

    static let urls: [NSURL] = [
        NSURL(string: "https://placehold.it/1920x1080"),
        NSURL(string: "https://placehold.it/1080x1920"),
        NSURL(string: "https://placehold.it/350x150"),
        NSURL(string: "https://placehold.it/150x350"),
        ].flatMap { $0 }

    func loadImages() -> RIGImageGalleryViewController {

        let urls = self.dynamicType.urls

        let rigItems = urls.map { _ in
            RIGImageGalleryItem(placeholderImage: UIImage(named: "placeholder") ?? UIImage())
        }

        let rigController = RIGImageGalleryViewController(images: rigItems)

        for (index, URL) in urls.enumerate() {
            let completion = rigController.handleImageLoadAtIndex(index)
            let request = imageSession.dataTaskWithRequest(NSURLRequest(URL: URL), completionHandler: completion)
            request.resume()
        }

        rigController.setCurrentImage(2, animated: false)
        return rigController
    }

    func navBarWrappedViewController(viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barStyle = .BlackTranslucent
        navigationController.navigationBar.tintColor = .whiteColor()
        navigationController.toolbar.barStyle = .BlackTranslucent
        navigationController.toolbar.tintColor = .whiteColor()
        return navigationController
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
                self?.images[index].image = image
            }
        }
    }
}
