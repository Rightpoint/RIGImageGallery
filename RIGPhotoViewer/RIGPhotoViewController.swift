//
//  RIGPhotoViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

public typealias RIGImageViewConstructor = () -> UIImageView
public typealias RIGImageURLLoader = (imageView: UIImageView, url: NSURL) -> Void
public typealias RIGImageLoaderCleanup = (imageView: UIImageView) -> Void

public protocol RIGPhotoViewControllerDelegate {

    func dismissPhotoViewer()

}

public class RIGPhotoViewerImage {

    public let image: UIImage?
    public let placeholderImage: UIImage?
    public let title: String?

    public var displayImage: UIImage? {
        return image ?? placeholderImage
    }

    public func updateImage(image:UIImage?) -> RIGPhotoViewerImage {
        return RIGPhotoViewerImage(image: image, placeholderImage: placeholderImage, title: title)
    }

    public init(image: UIImage? = nil, placeholderImage: UIImage? = nil, title: String? = nil) {
        self.image = image
        self.placeholderImage = placeholderImage
        self.title = title
    }

}

public class RIGPhotoViewController: UIViewController {

    private let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])

    public var photoViewDelegate: RIGPhotoViewControllerDelegate?
    public var placeholder: UIImage? = nil
    public var images: [RIGPhotoViewerImage] = [] {
        willSet {
            if pageViewController.viewControllers?.isEmpty ?? true {
                let newView = RIGImageZoomView()
                let activeItem = newValue[currentImage]
                newView.photoImage = activeItem
                pageViewController.setViewControllers([newView], direction: .Forward, animated: false, completion: nil)
            }
            guard let index = indexOfCurrentViewer() where index < pageViewController.viewControllers?.count ?? 0,
                let activeView = pageViewController.viewControllers?[index] as? RIGImageZoomView else {
                    return
            }
            let oldValue = images
            if newValue[index] !== oldValue[index] {
                activeView.photoImage = newValue[index]
            }
        }
    }

    public var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    public var currentImage: Int = 0 {
        didSet {
            let newView = RIGImageZoomView()
            newView.photoImage = images[currentImage]
            let direction: UIPageViewControllerNavigationDirection
            if oldValue < currentImage {
                direction = .Forward
            }
            else {
                direction = .Reverse
            }
            pageViewController.setViewControllers([newView], direction: direction, animated: true, completion: nil)
        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        pageViewController.dataSource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = UIView()
        view.clipsToBounds = false
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        configureDoneButton()
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.leftBarButtonItem = doneButton
        view.backgroundColor = UIColor.blackColor()
        configureConstraints()
    }

    public override func viewWillAppear(animated: Bool) {
        navigationController?.toolbarHidden = false
        let photoPage = RIGImageZoomView()
        if currentImage < images.count {
            photoPage.photoImage = images[currentImage]
            pageViewController.setViewControllers([photoPage], direction: .Forward, animated: false, completion: nil)
        }
    }

}

// MARK: - Actions

internal extension RIGPhotoViewController {

    func dismissPhotoView(sender: UIBarButtonItem) {
        if let pDelegate = photoViewDelegate {
            pDelegate.dismissPhotoViewer()
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}

// MARK: - Private

private extension RIGPhotoViewController {

    func configureDoneButton() {
        doneButton.target = self
        doneButton.action = "dismissPhotoView:"
    }
//
//    func updateImageFrame() {
//        view.layoutSubviews()
//        guard !CGRectEqualToRect(CGRect.zero, scrollView.frame), let img = activeImage.image else {
//            return
//        }
//        let size = img.size
//        activeImage.frame = CGRect(origin: CGPoint(), size: size)
//        scrollView.minimumZoomScale = scrollView.frame.size.minZoomScale(size: size)
//        scrollView.maximumZoomScale = scrollView.maximumZoomScale * self.dynamicType.zoomMultiplier
//        scrollView.zoomToRect(activeImage.frame, animated: false)
//        let vOffset = scrollView.frame.size.relativeYOffset(size: size) - (self.topLayoutGuide.length / 2)
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.scrollView.contentOffset = CGPoint(x: 0, y: -vOffset)
//        }
//    }
//
//    func configureConstraints() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//
//        let constraints: [NSLayoutConstraint] = [
//            scrollView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
//            scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
//            view.trailingAnchor.constraintEqualToAnchor(scrollView.trailingAnchor),
//            bottomLayoutGuide.topAnchor.constraintEqualToAnchor(scrollView.bottomAnchor),
//        ]
//
//        NSLayoutConstraint.activateConstraints(constraints)
//    }
}

extension RIGPhotoViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfPhotoViewer(viewController as? RIGImageZoomView)?.successor()
            where index < images.count else {
            return nil
        }
        let zoomView = RIGImageZoomView()
        zoomView.photoImage = images[index]
        return zoomView
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfPhotoViewer(viewController as? RIGImageZoomView)?.predecessor()
            where index >= 0 else {
                return nil
        }
        let zoomView = RIGImageZoomView()
        zoomView.photoImage = images[index]
        return zoomView
    }

    private func indexOfCurrentViewer() -> Int? {
        guard currentImage < pageViewController.viewControllers?.count ?? 0 else {
            return nil
        }
        return indexOfPhotoViewer(pageViewController.viewControllers?[currentImage] as? RIGImageZoomView)
    }

    private func indexOfPhotoViewer(photoViewer: RIGImageZoomView?) -> Int? {
        guard let viewer = photoViewer else {
            return nil
        }
        return indexOfItem(viewer.photoImage)
    }

    private func indexOfItem(item: RIGPhotoViewerImage?) -> Int? {
        guard let item = item else {
            return nil
        }
        let index = images.indexOf { img in
            return img === item
        }
        return index
    }

}

private extension RIGPhotoViewController {

    func configureConstraints() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            pageViewController.view.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            pageViewController.view.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor),
            pageViewController.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
        ]

        NSLayoutConstraint.activateConstraints(constraints)
    }
}
