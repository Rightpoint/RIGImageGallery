//
//  RIGAutoCenteringScrollView.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

internal class RIGAutoCenteringScrollView: UIScrollView {

    var lastZoomScale: CGFloat?

    var zoomImage: UIImage? {
        didSet {
            if let img = zoomImage {
                let imageView: UIImageView
                if let img = contentView {
                    imageView = img
                }
                else {
                    imageView = UIImageView()
                    contentView = imageView
                    addSubview(imageView)
                }
                imageView.frame = CGRect(origin: CGPoint(), size: img.size)
                imageView.image = img
            }
            else {
                contentView?.removeFromSuperview()
                contentView = nil
            }
            updateZoomScale()
        }
    }

    private var contentView: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var frame: CGRect {
        didSet {
            updateZoomScale()
        }
    }

}

internal extension RIGAutoCenteringScrollView {

    func centerView(tapRecognizer: UITapGestureRecognizer) {
        if zoomScale == minimumZoomScale {
            if let lastZoom = lastZoomScale {
                lastZoomScale = nil
                setZoomScale(lastZoom, animated: true)
            }
        }
        else {
            lastZoomScale = zoomScale
            setZoomScale(minimumZoomScale, animated: true)
        }

    }
}

private extension RIGAutoCenteringScrollView {

    func setupTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "centerView:")
        addGestureRecognizer(tapRecognizer)
    }

    func updateZoomScale() {
        guard let image = zoomImage else {
            contentSize = frame.size
            minimumZoomScale = 1
            maximumZoomScale = 1
            setZoomScale(1, animated: false)
            return
        }
        contentSize = image.size

        let wScale = frame.width / image.size.width
        let hScale = frame.height / image.size.height

        minimumZoomScale = min(wScale, hScale)
        maximumZoomScale = max(1, minimumZoomScale * 3)

        setZoomScale(minimumZoomScale, animated: false)
        centerContent()
    }

    func centerContent() {
        guard !CGSizeEqualToSize(contentSize, CGSize()) else {
            return
        }
        let vertical: CGFloat
        let horizontal: CGFloat

        if (contentSize.width < bounds.size.width) {
            horizontal = floor((bounds.size.width - contentSize.width) * 0.5)
        }
        else {
            horizontal = 0
        }

        if (contentSize.height < bounds.size.height) {
            vertical = floor((bounds.size.height - contentSize.height) * 0.5)
        }
        else {
            vertical = 0
        }

        self.contentInset = UIEdgeInsetsMake(vertical, horizontal, vertical, horizontal)
    }

}

extension RIGAutoCenteringScrollView: UIScrollViewDelegate {

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return contentView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerContent()
    }
}
