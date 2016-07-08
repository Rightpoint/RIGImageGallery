//
//  RIGImageGalleryViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

@objc public protocol RIGPhotoViewControllerDelegate {

    func dismissPhotoViewer()
    optional func showDismissForTraitCollection(traitCollection: UITraitCollection) -> Bool
    optional func actionForGalleryItem(galleryItem: RIGImageGalleryItem)
    optional func handleGalleryIndexUpdate(newIndex: Int)

}

public class RIGImageGalleryViewController: UIPageViewController {

    private var navigationBarsHidden: Bool = false
    private var zoomRecognizer = UITapGestureRecognizer()
    private var toggleBarRecognizer = UITapGestureRecognizer()
    private var currentImageViewController: RIGSingleImageViewController?

    public var photoViewDelegate: RIGPhotoViewControllerDelegate? {
        didSet {
            configureActionButton()
        }
    }

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
            updateCountText()
        }
    }

    public var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    public var actionButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: nil, action: nil) {
        didSet {
            configureActionButton()
        }
    }

    public private(set) var currentImage: Int = 0 {
        didSet {
            photoViewDelegate?.handleGalleryIndexUpdate?(currentImage)
            updateCountText()
        }
    }

    public func setCurrentImage(currentImage: Int, animated: Bool) {
        let newView = rigImageViewWithImage(images[currentImage])
        newView.viewIndex = currentImage
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

    public let countLabel: UILabel = {
        let counter = UILabel()
        counter.textColor = .whiteColor()
        counter.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        return counter
    }()

    public init() {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        configureDoneButton()
        zoomRecognizer.addTarget(self, action: #selector(RIGImageGalleryViewController.toggleZoom(_:)))
        zoomRecognizer.numberOfTapsRequired = 2
        zoomRecognizer.delegate = self
        toggleBarRecognizer.addTarget(self, action: #selector(RIGImageGalleryViewController.toggleBarVisiblity(_:)))
        toggleBarRecognizer.delegate = self
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(toggleBarRecognizer)
        view.backgroundColor = UIColor.blackColor()

        countLabel.sizeToFit()

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: countLabel),
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
        ]
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateBarStatus(animated: false)
        if currentImage < images.count {
            let photoPage = rigImageViewWithImage(images[currentImage])
            photoPage.viewIndex = currentImage
            currentImageViewController = photoPage
            setViewControllers([photoPage], direction: .Forward, animated: false, completion: nil)
        }
    }

    public override func prefersStatusBarHidden() -> Bool {
        return navigationBarsHidden
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentImageViewController?.scrollView.baseInsets = scrollViewInset
    }

    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureDoneButton()
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

extension RIGImageGalleryViewController {

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

    func performAction(sender: UIBarButtonItem) {
        if let item = currentImageViewController?.viewerItem {
            photoViewDelegate?.actionForGalleryItem?(item)
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
        doneButton.action = #selector(RIGImageGalleryViewController.dismissPhotoView(_:))
        if photoViewDelegate?.showDismissForTraitCollection?(traitCollection) ?? true {
            navigationItem.leftBarButtonItem = doneButton
        }
        else {
            navigationItem.leftBarButtonItem = nil
        }
    }

    func configureActionButton() {
        actionButton.target = self
        actionButton.action = #selector(RIGImageGalleryViewController.performAction(_:))
        if photoViewDelegate?.actionForGalleryItem != nil {
            navigationItem.rightBarButtonItem = actionButton
        }
        else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func rigImageViewWithImage(image: RIGImageGalleryItem) -> RIGSingleImageViewController {
        let imageView = RIGSingleImageViewController()
        imageView.viewerItem = image
        return imageView
    }

    private var scrollViewInset: UIEdgeInsets {
        loadViewIfNeeded()
        return UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
    }

    private func updateCountText() {
        countLabel.text = "\(currentImage.successor()) of \(images.count)"
        countLabel.sizeToFit()
    }
}
