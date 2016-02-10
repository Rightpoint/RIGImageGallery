//
//  RIGSingleImageViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

internal class RIGSingleImageViewController: UIViewController {

    var viewIndex:Int  = 0

    var viewerItem: RIGImageGalleryItem? {
        didSet {
            if viewerItem?.image != nil {
                scrollView.allowZoom = true
                scrollView.zoomImage = viewerItem?.image
            }
            else {
                scrollView.allowZoom = false
                scrollView.zoomImage = viewerItem?.placeholderImage
            }
        }
    }

    internal let scrollView = RIGAutoCenteringScrollView()

    override func loadView() {
        automaticallyAdjustsScrollViewInsets = false
        view = scrollView
        view.backgroundColor = .blackColor()
        view.clipsToBounds = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }

}
