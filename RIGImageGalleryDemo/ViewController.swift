//
//  ViewController.swift
//  RigPhotoViewerDemo
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import RIGImageGallery
import Alamofire
import AlamofireImage

class ViewController: UIViewController {

    var rigController: RIGImageGalleryViewController?

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
        self.rigController = photoViewController
        photoViewController.photoViewDelegate = self
        loadImages()
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

    func loadImages() {
        let reqs: [URLRequestConvertible] = urls.map { url in
            NSURLRequest(URL: url)
        }
        guard let rig = rigController else {
            return
        }
        let img = UIImage(named: "placeholder")
        rig.images = Array<RIGImageGalleryItem>.init(count: reqs.count, repeatedValue: RIGImageGalleryItem(placeholderImage: img))
        let downloader = ImageDownloader.defaultInstance
        downloader.downloadImages(URLRequests: reqs, filter: nil) { response in
            guard let request = response.request, let image = response.result.value else {
                return
            }
            let index = reqs.indexOf { req in
                request == req as? NSURLRequest
            }
            if let matchIndex = index {
                let update = rig.images[matchIndex].updateImage(image)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                rig.images[matchIndex] = update
                }
            }
        }
    }
}

