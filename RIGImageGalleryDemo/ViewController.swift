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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let urls: [NSURL] = [
        NSURL(string: "https://placehold.it/1920x1080"),
        NSURL(string: "https://placehold.it/1080x1920"),
        NSURL(string: "https://placehold.it/350x150"),
        NSURL(string: "https://placehold.it/150x350"),
        ].flatMap { $0 }

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
        return !traitCollection.containsTraitsInCollection(UITraitCollection(verticalSizeClass: .Compact))
    }

    static func parseImage(gallery gallery: RIGImageGalleryViewController, index: Int) -> ((NSData?, NSURLResponse?, NSError?) -> ()) {
        return { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            guard let image = data.flatMap(UIImage.init) where error == nil else {
                print(error)
                return
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                gallery.images[index] = gallery.images[index].updateImage(image)
            }
        }
    }

    func loadImages(rigController: RIGImageGalleryViewController) {
        let requests = urls.map { url in
            NSURLRequest(URL: url)
        }
        let placeHolder = UIImage(named: "placeholder")
        rigController.images = Array<RIGImageGalleryItem>.init(count: requests.count, repeatedValue: RIGImageGalleryItem(placeholderImage: placeHolder))

        rigController.images = requests.enumerate().map { (index, request) in
            let emptyItem = RIGImageGalleryItem(placeholderImage: placeHolder)
            imageSession.dataTaskWithRequest(request, completionHandler: self.dynamicType.parseImage(gallery: rigController, index: index)).resume()
            return emptyItem
        }
        rigController.setCurrentImage(1, animated: false)
    }
}
