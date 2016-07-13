//
//  RIGImageGalleryViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

public class RIGImageGalleryViewController: UIPageViewController {

    public var actionButtonHandler: (RIGImageGalleryItem -> ())?

    public var traitCollectionChangeHandler: ((RIGImageGalleryViewController, UITraitCollection) -> ())? {
        didSet {
            traitCollectionChangeHandler?(self, traitCollection)
        }
    }

    public var indexUpdateHandler: (Int -> ())?

    public var dismissTappedHandler: (() -> ())?

    public var images: [RIGImageGalleryItem] = [] {
        didSet {
            handleImagesUpdate(oldValue: oldValue)
        }
    }

    public var doneButton: UIBarButtonItem? = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    public var actionButton: UIBarButtonItem? {
        didSet {
            configureActionButton()
        }
    }

    public private(set) var currentImage: Int = 0 {
        didSet {
            indexUpdateHandler?(currentImage)
            updateCountText()
        }
    }

    private var navigationBarsHidden: Bool = false
    private var zoomRecognizer = UITapGestureRecognizer()
    private var toggleBarRecognizer = UITapGestureRecognizer()
    private var currentImageViewController: RIGSingleImageViewController?
    private var showDoneButton: Bool = true

    public func setCurrentImage(currentImage: Int, animated: Bool) {
        guard currentImage >= 0 && currentImage < images.count else {
            self.currentImage = 0
            setViewControllers([UIViewController()], direction: .Forward, animated: animated, completion: nil)
            return
        }
        let newView = RIGSingleImageViewController(viewerItem: images[currentImage])
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

    public convenience init() {
        self.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }

    public convenience init(images: [RIGImageGalleryItem]) {
        self.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        self.images = images
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
        handleImagesUpdate(oldValue: [])
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
            let photoPage =  RIGSingleImageViewController(viewerItem: images[currentImage])
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
        traitCollectionChangeHandler?(self, traitCollection)
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

    func dismissPhotoView(sender: UIBarButtonItem) {
        if let dismissHandler = dismissTappedHandler {
            dismissHandler()
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func performAction(sender: UIBarButtonItem) {
        if let item = currentImageViewController?.viewerItem {
            actionButtonHandler?(item)
        }
    }

}

extension RIGImageGalleryViewController: UIPageViewControllerDataSource {

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let index = indexOf(viewController: viewController)?.successor()
            where index < images.count else {
            return nil
        }
        let zoomView = RIGSingleImageViewController(viewerItem: images[index])
        return zoomView
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = indexOf(viewController: viewController)?.predecessor()
            where index >= 0 else {
                return nil
        }
        let zoomView = RIGSingleImageViewController(viewerItem: images[index])
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
        if let index = viewControllers?.first.flatMap({ self.indexOf(viewController: $0) }) {
            currentImage = index
        }
    }
}

// MARK: - Private

private extension RIGImageGalleryViewController {

    func indexOf(viewController viewController: UIViewController, imagesArray: [RIGImageGalleryItem]? = nil) -> Int? {
        guard let item = (viewController as? RIGSingleImageViewController)?.viewerItem else {
            return nil
        }
        let index = (imagesArray ?? images).indexOf(item)
        return index
    }

    func configureDoneButton() {
        doneButton?.target = self
        doneButton?.action = #selector(RIGImageGalleryViewController.dismissPhotoView(_:))
        navigationItem.leftBarButtonItem = doneButton
    }

    func configureActionButton() {
        actionButton?.target = self
        actionButton?.action = #selector(RIGImageGalleryViewController.performAction(_:))
        navigationItem.rightBarButtonItem = actionButton
    }

    func updateBarStatus(animated animated: Bool) {
        navigationController?.setToolbarHidden(navigationBarsHidden, animated: animated)
        navigationController?.setNavigationBarHidden(navigationBarsHidden, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        UIView.animateWithDuration(0.15) {
            self.currentImageViewController?.scrollView.baseInsets = self.scrollViewInset
        }
    }

    func handleImagesUpdate(oldValue oldValue: [RIGImageGalleryItem]) {
        for viewController in childViewControllers {
            if let index = indexOf(viewController: viewController, imagesArray: oldValue),
                childView = viewController as? RIGSingleImageViewController where index < images.count {
                childView.viewerItem = images[index]
                childView.scrollView.baseInsets = scrollViewInset
            }
        }
        updateCountText()
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
