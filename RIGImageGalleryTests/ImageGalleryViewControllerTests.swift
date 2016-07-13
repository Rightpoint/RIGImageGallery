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
        imageGallery = RIGImageGalleryViewController()
        imageGallery.loadView()
        imageGallery.viewDidLoad()
        imageGallery.view.frame = CGRect(x: 0, y: 0, width: 720, height: 480)
        imageGallery.images = UIImage.allGenerics.map({ RIGImageGalleryItem.init(image: $0) })
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
        imageGallery.dismissTappedHandler = {
            dismissFired.fulfill()
        }
        imageGallery.performSelector((imageGallery.navigationItem.leftBarButtonItem?.action)!, withObject: imageGallery)
        waitForExpectationsWithTimeout(1.0, handler: nil)

        let traitCollection = UITraitCollection(userInterfaceIdiom: .Phone)
        imageGallery.traitCollectionChangeHandler = { gallery, traits in
            gallery.doneButton = traits.containsTraitsInCollection(UITraitCollection(userInterfaceIdiom: .Phone)) ? nil : UIBarButtonItem()
        }
        imageGallery.traitCollectionChangeHandler?(imageGallery, traitCollection)
        XCTAssertNil(imageGallery.doneButton, "done button should be nil")
        imageGallery.traitCollectionChangeHandler?(imageGallery, UITraitCollection())
        XCTAssertNotNil(imageGallery.doneButton, "trait collection change handler should have restored it")
    }

    func testStatusBarHidden() {
        XCTAssertFalse(imageGallery.prefersStatusBarHidden())
        imageGallery.toggleBarVisiblity(UITapGestureRecognizer())
        XCTAssertTrue(imageGallery.prefersStatusBarHidden())
    }

    func testPageViewController() {
        XCTAssertNotNil(imageGallery.viewControllers?.first as? RIGSingleImageViewController)
        let firstView = imageGallery.viewControllers!.first as! RIGSingleImageViewController
        XCTAssertEqual(firstView.viewerItem, imageGallery.images.first, "The first view should have the first image in the gallery")
        XCTAssertNil(imageGallery.pageViewController(imageGallery, viewControllerBeforeViewController: firstView), "The view before the first view should be nil")
        let secondView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: firstView) as! RIGSingleImageViewController
        XCTAssertEqual(secondView.viewerItem, imageGallery.images[1], "The second view should have the second image in the gallery")
        XCTAssertEqual((imageGallery.pageViewController(imageGallery, viewControllerBeforeViewController: secondView) as! RIGSingleImageViewController).viewerItem, firstView.viewerItem, "the view before the second view should be the first view, which is testable by comparing viewer items")
        let thirdView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: secondView)!
        let fourthView = imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: thirdView)!
        XCTAssertNil(imageGallery.pageViewController(imageGallery, viewControllerAfterViewController: fourthView), "The view after the end of the list should be nil")
    }

}
