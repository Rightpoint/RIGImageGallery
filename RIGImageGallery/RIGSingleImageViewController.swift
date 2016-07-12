//
//  RIGSingleImageViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

class RIGSingleImageViewController: UIViewController {

    var viewerItem: RIGImageGalleryItem? {
        didSet {
            viewerItemUpdated()
        }
    }

    let scrollView = RIGAutoCenteringScrollView()

    convenience init(viewerItem: RIGImageGalleryItem) {
        self.init()
        self.viewerItem = viewerItem
        viewerItemUpdated()
    }

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

private extension RIGSingleImageViewController {
    func viewerItemUpdated() {
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
