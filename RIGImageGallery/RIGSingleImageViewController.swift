//
//  RIGSingleImageViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

open class RIGSingleImageViewController: UIViewController {

    open var viewerItem: RIGImageGalleryItem? {
        didSet {
            viewerItemUpdated()
        }
    }

    open let scrollView = RIGAutoCenteringScrollView()
    open var activityIndicator: UIActivityIndicatorView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let newValue = activityIndicator {
                view.addSubview(newValue)
                NSLayoutConstraint.activate([
                    newValue.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
                    newValue.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
                    ])
            }
        }
    }

    public convenience init(viewerItem: RIGImageGalleryItem) {
        self.init()
        self.viewerItem = viewerItem
        viewerItemUpdated()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.clipsToBounds = true
        view.addSubview(scrollView)
        let indicatorView = UIActivityIndicatorView()
        indicatorView.activityIndicatorViewStyle = .gray
        indicatorView.hidesWhenStopped = true
        self.activityIndicator = indicatorView
        configureConstraints()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewerItemUpdated()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }

}

private extension RIGSingleImageViewController {

    func viewerItemUpdated() {
        if viewerItem?.isLoading == true && activityIndicator?.isAnimating == false {
            activityIndicator?.startAnimating()
        }
        else if viewerItem?.isLoading == false && activityIndicator?.isAnimating == true {
            activityIndicator?.stopAnimating()
        }
        scrollView.allowZoom = viewerItem?.image != nil
        scrollView.isUserInteractionEnabled = viewerItem?.isLoading == false
        if !view.frame.isEmpty {
            scrollView.zoomImage = viewerItem?.image ?? viewerItem?.placeholderImage
        }
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }

    func configureConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
}
