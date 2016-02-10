//
//  RIGSingleImageViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

internal class RIGSingleImageViewController: UIViewController {

    var viewerItem: RIGImageGalleryItem? {
        didSet {
            scrollView.zoomImage = viewerItem?.displayImage
        }
    }

    var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    internal let scrollView = RIGAutoCenteringScrollView()

    override func loadView() {
        configureDoneButton()
        automaticallyAdjustsScrollViewInsets = false
        view = scrollView
        view.backgroundColor = .blackColor()
        view.clipsToBounds = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = doneButton
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }

}

extension RIGSingleImageViewController {

    func dismissPhotoView(sender: UINavigationItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

private extension RIGSingleImageViewController {

    func configureDoneButton() {
        doneButton.target = self
        doneButton.action = "dismissPhotoView:"
    }

}