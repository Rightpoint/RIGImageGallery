//
//  RIGAutoCenteringScrollView.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

open class RIGAutoCenteringScrollView: UIScrollView {

    internal var allowZoom: Bool = false

    internal var baseInsets: UIEdgeInsets = UIEdgeInsets() {
        didSet {
            updateZoomScale(preserveScale: true)
        }
    }

    open var zoomImage: UIImage? {
        didSet {
            if oldValue === zoomImage {
                return
            }
            if let img = zoomImage {
                contentView.isHidden = false
                contentView.image = img
            }
            else {
                contentView.isHidden = true
            }
            updateZoomScale(preserveScale: false)
        }
    }

    fileprivate var contentView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(contentView)
        configureConstraints()
        delegate = self
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var frame: CGRect {
        didSet {
            updateZoomScale(preserveScale: true)
        }
    }

}

extension RIGAutoCenteringScrollView {

    func toggleZoom(animated: Bool = true) {
        if self.isUserInteractionEnabled {
            if zoomScale != minimumZoomScale {
                setZoomScale(minimumZoomScale, animated: animated)
            }
            else {
                setZoomScale(maximumZoomScale, animated: animated)
            }
        }
    }

}

private extension RIGAutoCenteringScrollView {

    func configureConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    func updateZoomScale(preserveScale: Bool) {
        guard let image = zoomImage else {
            contentSize = frame.size
            minimumZoomScale = 1
            maximumZoomScale = 1
            setZoomScale(1, animated: false)
            return
        }
        updateConstraintsIfNeeded()
        layoutIfNeeded()

        let adjustedFrame = UIEdgeInsetsInsetRect(frame, baseInsets)

        let wScale = adjustedFrame.width / image.size.width
        let hScale = adjustedFrame.height / image.size.height

        let oldMin = minimumZoomScale

        minimumZoomScale = min(wScale, hScale)
        maximumZoomScale = max(1, minimumZoomScale * 3)

        if preserveScale {
            if zoomScale <= oldMin || zoomScale <= minimumZoomScale {
                contentSize = image.size
                setZoomScale(minimumZoomScale, animated: false)
            }
        }
        else {
            contentSize = image.size
            setZoomScale(minimumZoomScale, animated: false)
        }

        centerContent()
    }

    // After much fiddling, using insets to correct zoom behavior was found at: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
    func centerContent() {
        guard !contentSize.equalTo(CGSize()) else {
            return
        }
        let adjustedSize = UIEdgeInsetsInsetRect(bounds, baseInsets).size
        let vertical: CGFloat
        let horizontal: CGFloat

        if contentSize.width < adjustedSize.width {
            horizontal = floor((adjustedSize.width - contentSize.width) * 0.5)
        }
        else {
            horizontal = 0
        }

        if contentSize.height < adjustedSize.height {
            vertical = floor((adjustedSize.height - contentSize.height) * 0.5)
        }
        else {
            vertical = 0
        }

        contentInset = UIEdgeInsets(top: vertical + baseInsets.top, left: horizontal + baseInsets.left, bottom: vertical + baseInsets.bottom, right: horizontal + baseInsets.right)

        updateConstraintsIfNeeded()
        layoutIfNeeded()
    }

}

extension RIGAutoCenteringScrollView: UIScrollViewDelegate {

    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return allowZoom ? contentView : nil
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerContent()
    }

}
