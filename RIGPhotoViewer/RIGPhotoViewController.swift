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

public class RIGPhotoViewController: UIPageViewController {

//    private let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])

    private var navigationBarsHidden: Bool = false

    public var photoViewDelegate: RIGPhotoViewControllerDelegate?
    public var placeholder: UIImage? = nil
    public var images: [RIGPhotoViewerItem] = [] {
        willSet {
            if viewControllers?.isEmpty ?? true {
                let newView = RIGImageViewController()
//                newView.scrollView.contentInset = scrollViewInset
                let viewerItem = newValue[currentImage]
                newView.viewerItem = viewerItem
                setViewControllers([newView], direction: .Forward, animated: false, completion: nil)
            }
            guard let index = indexOfCurrentViewer() where index < viewControllers?.count ?? 0,
                let activeView = viewControllers?[index] as? RIGImageViewController else {
                    return
            }
            let oldValue = images
            if newValue[index] !== oldValue[index] {
                activeView.viewerItem = newValue[index]
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
            let newView = RIGImageViewController()
//            newView.scrollView.contentInset = scrollViewInset
            newView.viewerItem = images[currentImage]
            let direction: UIPageViewControllerNavigationDirection
            if oldValue < currentImage {
                direction = .Forward
            }
            else {
                direction = .Reverse
            }
            setViewControllers([newView], direction: direction, animated: true, completion: nil)
        }
    }

    public init() {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        dataSource = self
        automaticallyAdjustsScrollViewInsets = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        configureDoneButton()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "toggleBarVisiblity")
        view.addGestureRecognizer(tapGestureRecognizer)
        navigationItem.leftBarButtonItem = doneButton
        view.backgroundColor = UIColor.blackColor()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateBarStatus()
        let photoPage = RIGImageViewController()
//        photoPage.scrollView.contentInset = scrollViewInset
        if currentImage < images.count {
            photoPage.viewerItem = images[currentImage]
            setViewControllers([photoPage], direction: .Forward, animated: false, completion: nil)
        }
    }

    public override func prefersStatusBarHidden() -> Bool {
        return navigationBarsHidden
    }

}

// MARK: - Actions

internal extension RIGPhotoViewController {

    func toggleBarVisiblity() {
        navigationBarsHidden = !navigationBarsHidden
        updateBarStatus()
    }

    func updateBarStatus() {
        navigationController?.setToolbarHidden(navigationBarsHidden, animated: true)
        navigationController?.setNavigationBarHidden(navigationBarsHidden, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }

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
        guard let index = indexOfPhotoViewer(viewController as? RIGImageViewController)?.successor()
            where index < images.count else {
            return nil
        }
        let zoomView = RIGImageViewController()
        zoomView.viewerItem = images[index]
        return zoomView
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfPhotoViewer(viewController as? RIGImageViewController)?.predecessor()
            where index >= 0 else {
                return nil
        }
        let zoomView = RIGImageViewController()
        zoomView.viewerItem = images[index]
        return zoomView
    }
}

private extension RIGPhotoViewController {

    func indexOfCurrentViewer() -> Int? {
        guard currentImage < viewControllers?.count ?? 0 else {
            return nil
        }
        return indexOfPhotoViewer(viewControllers?[currentImage] as? RIGImageViewController)
    }

    func indexOfPhotoViewer(photoViewer: RIGImageViewController?) -> Int? {
        guard let viewer = photoViewer else {
            return nil
        }
        return indexOfItem(viewer.viewerItem)
    }

    func indexOfItem(item: RIGPhotoViewerItem?) -> Int? {
        guard let item = item else {
            return nil
        }
        let index = images.indexOf { img in
            return img === item
        }
        return index
    }

//    private var scrollViewInset: UIEdgeInsets {
//        loadViewIfNeeded()
//        return UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
//    }
}
