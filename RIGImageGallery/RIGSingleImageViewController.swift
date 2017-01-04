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
    open let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    public convenience init(viewerItem: RIGImageGalleryItem) {
        self.init()
        self.viewerItem = viewerItem
        viewerItemUpdated()
    }

    open override func loadView() {
        automaticallyAdjustsScrollViewInsets = false
        view = UIView()
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        view.backgroundColor = .black
        view.clipsToBounds = true
        configureConstraints()
        view.setNeedsLayout()
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
        if viewerItem?.isLoading == true && !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
        else if viewerItem?.isLoading == false && activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        scrollView.allowZoom = viewerItem?.image != nil
        scrollView.isUserInteractionEnabled = viewerItem?.isLoading == false
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        if !view.frame.isEmpty {
            scrollView.zoomImage = viewerItem?.image ?? viewerItem?.placeholderImage
        }
    }

    func configureConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
            ])
    }
}
