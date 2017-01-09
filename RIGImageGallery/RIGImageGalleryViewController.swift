//
//  RIGImageGalleryViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

open class RIGImageGalleryViewController: UIPageViewController {

    public typealias GalleryPositionUpdateHandler = (_ gallery: RIGImageGalleryViewController, _ position: Int, _ total: Int) -> Void
    public typealias ActionButtonPressedHandler = (_ gallery: RIGImageGalleryViewController, _ item: RIGImageGalleryItem) -> Void
    public typealias GalleryEventHandler = (RIGImageGalleryViewController) -> Void
    public typealias IndexUpdateHandler = (Int) -> Void

    /// An optional closure to execute if the action button is tapped
    open var actionButtonHandler: ActionButtonPressedHandler?

    /// An optional closure to allow cutom trait collection change handling
    open var traitCollectionChangeHandler: GalleryEventHandler? {
        didSet {
            traitCollectionChangeHandler?(self)
        }
    }

    /// An optional closure to execute when the active index is updated
    open var indexUpdateHandler: IndexUpdateHandler?

    /// An optional closure to handle dismissing the gallery, if this is nil the view will call `dismissViewControllerAnimated(true, completion: nil)`, if this is non-nil, the view controller will not dismiss itself
    open var dismissHandler: GalleryEventHandler?

    /// An optional closure to handle updating the count text
    open var countUpdateHandler: GalleryPositionUpdateHandler? {
        didSet {
            updateCountText()
        }
    }

    /// The array of images to display. The view controller will automatically handle updates
    open var images: [RIGImageGalleryItem] = [] {
        didSet {
            handleImagesUpdate(oldValue: oldValue)
        }
    }

    /// The bar button item to use for the left side of the screen, `didSet` adds the correct target and action to ensure that `dismissHandler` is called when the button is pressed
    open var doneButton: UIBarButtonItem? = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    /// The bar button item to use for the right side of the screen, `didSet` adds the correct target and action to ensure that `actionButtonHandler` is called
    open var actionButton: UIBarButtonItem? {
        didSet {
            configureActionButton()
        }
    }

    /// The index of the image currently bieng displayed
    open fileprivate(set) var currentImage: Int = 0 {
        didSet {
            indexUpdateHandler?(currentImage)
            updateCountText()
        }
    }

    fileprivate var navigationBarsHidden = false
    fileprivate var zoomRecognizer = UITapGestureRecognizer()
    fileprivate var toggleBarRecognizer = UITapGestureRecognizer()
    fileprivate var currentImageViewController: RIGSingleImageViewController? {
        return viewControllers?.first as? RIGSingleImageViewController
    }
    fileprivate var showDoneButton = true

    /**
     Changes the current image bieng displayed

     - parameter currentImage: The index of the image in `images` to display
     - parameter animated:     A flag that determines if this should be an animated or non-animated transition
     */
    open func setCurrentImage(_ currentImage: Int, animated: Bool) {
        guard currentImage >= 0 && currentImage < images.count else {
            self.currentImage = 0
            setViewControllers([UIViewController()], direction: .forward, animated: animated, completion: nil)
            return
        }
        let newView = createNewPage(for: images[currentImage])
        let direction: UIPageViewControllerNavigationDirection
        if self.currentImage < currentImage {
            direction = .forward
        }
        else {
            direction = .reverse
        }
        self.currentImage = currentImage
        setViewControllers([newView], direction: direction, animated: animated, completion: nil)
    }

    /// The label used to display the current position in the array
    open let countLabel: UILabel = {
        let counter = UILabel()
        counter.textColor = .white
        counter.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        return counter
    }()

    /**
     A convenience initializer to return a configured empty RIGImageGalleryViewController
     */
    public convenience init() {
        self.init(images: [])
    }

    /**
     A convenience initializer to return a configured RIGImageGalleryViewController with an array of images

     - parameter images: The images to use in the gallery
     */
    public convenience init(images: [RIGImageGalleryItem]) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        self.images = images
    }

    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        dataSource = self
        delegate = self
        automaticallyAdjustsScrollViewInsets = false
        handleImagesUpdate(oldValue: [])
        configureDoneButton()
        configureActionButton()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        configureDoneButton()
        zoomRecognizer.addTarget(self, action: #selector(toggleZoom(_:)))
        zoomRecognizer.numberOfTapsRequired = 2
        zoomRecognizer.delegate = self
        toggleBarRecognizer.addTarget(self, action: #selector(toggleBarVisiblity(_:)))
        toggleBarRecognizer.delegate = self
        view.addGestureRecognizer(zoomRecognizer)
        view.addGestureRecognizer(toggleBarRecognizer)
        view.backgroundColor = UIColor.black
        countLabel.sizeToFit()

        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: countLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
        ]
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBarStatus(animated: false)
        if currentImage < images.count {
            let photoPage = createNewPage(for: images[currentImage])
            setViewControllers([photoPage], direction: .forward, animated: false, completion: nil)
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return navigationBarsHidden
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentImageViewController?.scrollView.baseInsets = scrollViewInset
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChangeHandler?(self)
    }

    /// Allows subclasses of RIGImageGallery to customize the gallery page
    ///
    /// - Parameter viewerItem: The item to be displayed
    /// - Returns: The view controller that will display the item
    open func createNewPage(for viewerItem: RIGImageGalleryItem) -> UIViewController {
        return RIGSingleImageViewController(viewerItem: viewerItem)
    }

}

extension RIGImageGalleryViewController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == zoomRecognizer {
            return otherGestureRecognizer == toggleBarRecognizer
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == toggleBarRecognizer {
            return otherGestureRecognizer == zoomRecognizer
        }
        return false
    }

}

// MARK: - Actions

extension RIGImageGalleryViewController {

    func toggleBarVisiblity(_ recognizer: UITapGestureRecognizer) {
        navigationBarsHidden = !navigationBarsHidden
        updateBarStatus(animated: true)
    }

    func toggleZoom(_ recognizer: UITapGestureRecognizer) {
        currentImageViewController?.scrollView.toggleZoom()
    }

    func dismissPhotoView(_ sender: UIBarButtonItem) {
        if dismissHandler != nil {
            dismissHandler?(self)
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }

    func performAction(_ sender: UIBarButtonItem) {
        if let item = currentImageViewController?.viewerItem {
            actionButtonHandler?(self, item)
        }
    }

}

extension RIGImageGalleryViewController: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = indexOf(viewController: viewController), index < images.count - 1 else {
            return nil
        }
        return createNewPage(for: images[index + 1])
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = indexOf(viewController: viewController), index > 0 else {
            return nil
        }
        return createNewPage(for: images[index + -1])
    }

}

extension RIGImageGalleryViewController: UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        for viewControl in pendingViewControllers {
            if let imageControl = viewControl as? RIGSingleImageViewController {
                imageControl.scrollView.baseInsets = scrollViewInset
            }
        }
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let index = viewControllers?.first.flatMap({ indexOf(viewController: $0) }) {
            currentImage = index
        }
    }
}

// MARK: - Private

private extension RIGImageGalleryViewController {

    func indexOf(viewController: UIViewController, imagesArray: [RIGImageGalleryItem]? = nil) -> Int? {
        guard let item = (viewController as? RIGSingleImageViewController)?.viewerItem else {
            return nil
        }
        return (imagesArray ?? images).index(of: item)
    }

    func configureDoneButton() {
        doneButton?.target = self
        doneButton?.action = #selector(dismissPhotoView(_:))
        navigationItem.leftBarButtonItem = doneButton
    }

    func configureActionButton() {
        actionButton?.target = self
        actionButton?.action = #selector(performAction(_:))
        navigationItem.rightBarButtonItem = actionButton
    }

    func updateBarStatus(animated: Bool) {
        navigationController?.setToolbarHidden(navigationBarsHidden, animated: animated)
        navigationController?.setNavigationBarHidden(navigationBarsHidden, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        UIView.animate(withDuration: 0.2, animations: {
            self.currentImageViewController?.scrollView.baseInsets = self.scrollViewInset
        })
    }

    func handleImagesUpdate(oldValue: [RIGImageGalleryItem]) {
        for viewController in childViewControllers {
            if let index = indexOf(viewController: viewController, imagesArray: oldValue),
                let childView = viewController as? RIGSingleImageViewController, index < images.count {
                DispatchQueue.main.async { [unowned self] in
                    childView.viewerItem = self.images[index]
                    childView.scrollView.baseInsets = self.scrollViewInset
                }
            }
        }
        updateCountText()
    }

    var scrollViewInset: UIEdgeInsets {
        loadViewIfNeeded()
        return UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
    }

    func updateCountText() {
        if countUpdateHandler != nil {
            countUpdateHandler?(self, currentImage, images.count)
        }
        else {
            countLabel.text = nil
        }
        countLabel.sizeToFit()
    }

}
