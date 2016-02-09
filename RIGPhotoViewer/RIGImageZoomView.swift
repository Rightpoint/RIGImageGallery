//
//  RIGImageZoomView.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

internal class RIGImageZoomView: UIViewController {

    var photoImage: RIGPhotoViewerImage? {
        didSet {
            imageView.image = photoImage?.displayImage
        }
    }

    let scrollView = UIScrollView()

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()

    override func loadView() {
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        automaticallyAdjustsScrollViewInsets = false
        view = scrollView
        view.backgroundColor = .blackColor()
        view.clipsToBounds = false
        configureConstraints()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if !CGRectEqualToRect(scrollView.bounds, CGRect.zero) {
            scrollView.scrollRectToVisible(imageView.frame, animated: false)
            scrollView.zoomScale = 1
        }
    }

}

// MARK: - Scroll View Delegate

extension RIGImageZoomView: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}

private extension RIGImageZoomView {

    func configureConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            imageView.widthAnchor.constraintEqualToAnchor(scrollView.widthAnchor),
            imageView.heightAnchor.constraintEqualToAnchor(scrollView.heightAnchor),
        ]
        NSLayoutConstraint.activateConstraints(constraints)
    }

}