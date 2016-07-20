//
//  ImageGalleryViewControllerTests.swift
//  RIGImageGallery
//
//  Created by Michael Skiba on 7/12/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RIGImageGallery

class ImageGalleryViewControllerTests: XCTestCase {

    var imageGallery = RIGImageGalleryViewController()

    override func setUp() {
        super.setUp()
        let images = UIImage.allGenerics.map({ RIGImageGalleryItem.init(image: $0) })
        imageGallery = RIGImageGalleryViewController(images: images)
        imageGallery.loadView()
        imageGallery.viewDidLoad()
        imageGallery.view.frame = CGRect(x: 0, y: 0, width: 720, height: 480)
        imageGallery.viewWillLayoutSubviews()
        imageGallery.viewWillAppear(false)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChangingImages() {
        imageGallery.images = Array(imageGallery.images.prefix(3))
        imageGallery.setCurrentImage(2, animated: false)
        XCTAssertNil(imageGallery.countLabel.text, "Count label should be empty by default")
        imageGallery.countUpdateHandler = RIGImageGalleryViewController.updateCount
        XCTAssertNotNil(imageGallery.countLabel.text, "Count label should no longer be empty after setting update count")
        imageGallery.images = [RIGImageGalleryItem(image: UIImage.genericImage(.wide))]
        imageGallery.setCurrentImage(2, animated: false)
        XCTAssertEqual(imageGallery.currentImage, 0, "Making making sure the current selected image is 0")
        XCTAssertEqual(imageGallery.images.count, 1, "Making sure the gallery only contains 1 view")
        imageGallery.images = []
        XCTAssertEqual(imageGallery.images.count, 0, "Making sure the gallery has no views")
        imageGallery.setCurrentImage(2, animated: false)
        XCTAssertEqual(imageGallery.currentImage, 0, "Making making sure the current selected image is 0")
        imageGallery.images = UIImage.allGenerics.map({ RIGImageGalleryItem.init(image: $0) })
        XCTAssertEqual(imageGallery.images.count, 4, "Making sure the gallery has 4 views")
        XCTAssertEqual(imageGallery.currentImage, 0, "Making making sure the current selected image is 0")
        imageGallery.setCurrentImage(2, animated: false)
        XCTAssertEqual(imageGallery.currentImage, 2, "Making sure current selected image updated")
        imageGallery.setCurrentImage(0, animated: true)
        XCTAssertEqual(imageGallery.currentImage, 0, "Making sure current selected image updated")
        imageGallery = RIGImageGalleryViewController()
        XCTAssertTrue(imageGallery.images.isEmpty, "Making sure a new image gallery is initalized empty")
    }

    func testDelegateAndBarButtons() {
        // code coverage of the no delegate dismiss function
        imageGallery.dismissPhotoView(UIBarButtonItem())
        imageGallery.actionButton = UIBarButtonItem()
        let actionFired = self.expectationWithDescription("action will fire on completion")
        imageGallery.actionButtonHandler = { _ in
            actionFired.fulfill()
        }
        imageGallery.performSelector((imageGallery.navigationItem.rightBarButtonItem?.action)!, withObject: imageGallery)
        waitForExpectationsWithTimeout(1.0, handler: nil)
        imageGallery.doneButton = UIBarButtonItem()
        let dismissFired = expectationWithDescription("dismiss handler will fire on completion")
        imageGallery.dismissHandler = { _ in
            dismissFired.fulfill()
        }
        imageGallery.performSelector((imageGallery.navigationItem.leftBarButtonItem?.action)!, withObject: imageGallery)
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testStatusBarHidden() {
        XCTAssertFalse(imageGallery.prefersStatusBarHidden())
        imageGallery.toggleBarVisiblity(UITapGestureRecognizer())
        XCTAssertTrue(imageGallery.prefersStatusBarHidden())
    }

    func testPageViewController() {
        XCTAssertNotNil(imageGallery.viewControllers?.first as? RIGSingleImageViewController)
        // swiftlint:disable:next force_cast
        let firstView = imageGallery.viewControllers!.first as! RIGSingleImageViewController
        XCTAssertEqual(firstView.viewerItem, imageGallery.images.first, "The first view should have the first image in the gallery")
        XCTAssertNil(imageGallery.pageViewController(imageGallery, viewControllerBeforeViewController: firstView), "The view before the first view should be nil")
        // swiftlint:disable:next force_cast
        let secondView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: firstView) as! RIGSingleImageViewController
        XCTAssertEqual(secondView.viewerItem, imageGallery.images[1], "The second view should have the second image in the gallery")
        // swiftlint:disable:next force_cast
        XCTAssertEqual((imageGallery.pageViewController(imageGallery, viewControllerBeforeViewController: secondView) as! RIGSingleImageViewController).viewerItem, firstView.viewerItem, "the view before the second view should be the first view, which is testable by comparing viewer items")
        let thirdView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: secondView)!
        let fourthView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: thirdView)!
        XCTAssertNil(imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: fourthView), "The view after the end of the list should be nil")
    }

}

private extension RIGImageGalleryViewController {
    static func updateCount(gallery: RIGImageGalleryViewController, position: Int, total: Int) {
        gallery.countLabel.text = "\(position.successor()) of \(total)"
    }
}
