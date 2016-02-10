//
//  RIGImageGalleryViewController.swift
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

public class RIGImageGalleryViewController: UIPageViewController {

    private var navigationBarsHidden: Bool = false

    private var zoomRecognizer = UITapGestureRecognizer()
    private var toggleBarRecognizer = UITapGestureRecognizer()

    private var currentImageViewController: RIGSingleImageViewController?

    public var photoViewDelegate: RIGPhotoViewControllerDelegate?
    public var placeholder: UIImage? = nil
    public var images: [RIGImageGalleryItem] = [] {
        didSet {
            for childView in childViewControllers {
                if let indexedView = childView as? RIGSingleImageViewController
                    where indexedView.viewIndex < images.count {
                        indexedView.viewerItem = images[indexedView.viewIndex]
                        indexedView.scrollView.baseInsets = scrollViewInset
                }
            }
        }
    }

    public var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    public private(set) var currentImage: Int = 0

    public func setCurrentImage(currentImage: Int, animated: Bool) {
        let newView = rigImageViewWithImage(images[currentImage])
        let direction: UIPageViewControllerNavigationDirection
        if self.currentImage < currentImage {
            direction = .Forward
        }
        else {
            direction = .Reverse
        }
        self.currentImage = currentImage
        setViewControllers([newView], direction: direction, animated: animated, completion: nil)

    }

    public init() {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        configureDoneButton()
        zoomRecognizer.addTarget(self, action: "toggleZoom:")
        zoomRecognizer.numberOfTapsRequired = 2
        zoomRecognizer.delegate = self
        toggleBarRecognizer.addTarget(self, action: "toggleBarVisiblity:")
        toggleBarRecognizer.delegate = self
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(toggleBarRecognizer)
        navigationItem.leftBarButtonItem = doneButton
        view.backgroundColor = UIColor.blackColor()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateBarStatus(animated: false)
        if currentImage < images.count {
            let photoPage = rigImageViewWithImage(images[currentImage])
            currentImageViewController = photoPage
            setViewControllers([photoPage], direction: .Forward, animated: false, completion: nil)
        }
    }

    public override func prefersStatusBarHidden() -> Bool {
        return navigationBarsHidden
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentImageViewController?.scrollView.baseInsets = scrollViewInset
    }

}

extension RIGImageGalleryViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == zoomRecognizer {
            return otherGestureRecognizer == toggleBarRecognizer
        }
        return false
    }

    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == toggleBarRecognizer {
            return otherGestureRecognizer == zoomRecognizer
        }
        return false
    }

}

// MARK: - Actions

internal extension RIGImageGalleryViewController {

    func toggleBarVisiblity(recognizer: UITapGestureRecognizer) {
        navigationBarsHidden = !navigationBarsHidden
        updateBarStatus(animated: true)
    }

    func toggleZoom(recognizer: UITapGestureRecognizer) {
        currentImageViewController?.scrollView.toggleZoom()
    }

    func updateBarStatus(animated animated: Bool) {
        navigationController?.setToolbarHidden(navigationBarsHidden, animated: animated)
        navigationController?.setNavigationBarHidden(navigationBarsHidden, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        UIView.animateWithDuration(0.15) {
            self.currentImageViewController?.scrollView.baseInsets = self.scrollViewInset
        }
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

extension RIGImageGalleryViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let index = (viewController as? RIGSingleImageViewController)?.viewIndex.successor()
            where index < images.count else {
            return nil
        }
        let zoomView = rigImageViewWithImage(images[index])
        zoomView.viewIndex = index
        return zoomView
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? RIGSingleImageViewController)?.viewIndex.predecessor()
            where index >= 0 else {
                return nil
        }
        let zoomView = rigImageViewWithImage(images[index])
        zoomView.viewIndex = index
        return zoomView
    }

}

extension RIGImageGalleryViewController: UIPageViewControllerDelegate {

    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        for viewControl in pendingViewControllers {
            if let imageControl = viewControl as? RIGSingleImageViewController {
                imageControl.scrollView.baseInsets = scrollViewInset
            }
        }
    }

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        currentImageViewController = viewControllers?.first as? RIGSingleImageViewController
        if let index = currentImageViewController?.viewIndex {
            currentImage = index
        }
    }
}

// MARK: - Private

private extension RIGImageGalleryViewController {

    func configureDoneButton() {
        doneButton.target = self
        doneButton.action = "dismissPhotoView:"
    }
    
//    func indexOfCurrentViewer() -> Int? {
//        guard currentImage < viewControllers?.count ?? 0 else {
//            return nil
//        }
//        return indexOfPhotoViewer(viewControllers?[currentImage] as? RIGSingleImageViewController)
//    }

//    func indexOfPhotoViewer(photoViewer: RIGSingleImageViewController?) -> Int? {
//        guard let viewer = photoViewer else {
//            return nil
//        }
//        return indexOfItem(viewer.viewerItem)
//    }

//    func indexOfItem(item: RIGImageGalleryItem?) -> Int? {
//        guard let item = item else {
//            return nil
//        }
//        let index = images.indexOf { img in
//            return img == item
//        }
//        return index
//    }

    private func rigImageViewWithImage(image: RIGImageGalleryItem) -> RIGSingleImageViewController {
        let imageView = RIGSingleImageViewController()
        imageView.viewerItem = image
        return imageView
    }

    private var scrollViewInset: UIEdgeInsets {
        loadViewIfNeeded()
        return UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
    }

}
