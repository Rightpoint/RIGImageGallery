//
//  ViewController.swift
//  RigPhotoViewerDemo
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit
import RIGPhotoViewer
import Alamofire
import AlamofireImage

class ViewController: UIViewController {

    var rigController: RIGPhotoViewController?

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
        let photoViewController = RIGPhotoViewController()
        self.rigController = photoViewController
        photoViewController.photoViewDelegate = self
        loadImages()
        let navigationController = navBarWrappedViewController(photoViewController)
        presentViewController(navigationController, animated: true, completion: nil)
    }

    @IBAction func showSingle(sender: UIButton) {
        let photoView = RIGImageViewController()
        let navigationController = navBarWrappedViewController(photoView)
        guard let firstURL = urls.first else {
            return
        }
        let request = NSURLRequest(URL: firstURL)
        photoView.viewerItem = RIGPhotoViewerItem()
        ImageDownloader.defaultInstance.downloadImage(URLRequest: request, filter: nil) { response in
            if let image = response.result.value {
                photoView.viewerItem = photoView.viewerItem?.updateImage(image)
            }
        }
        presentViewController(navigationController, animated: true, completion: nil)
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
        rig.images = Array<RIGPhotoViewerItem>.init(count: reqs.count, repeatedValue: RIGPhotoViewerItem())
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
                rig.images[matchIndex] = update
            }
        }
    }
}

