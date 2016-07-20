//
//  SingleImageViewControllerTests.swift
//  RIGImageGallery
//
//  Created by Michael Skiba on 7/12/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
@testable import RIGImageGallery

class SingleImageViewControllerTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSettingImages() {
        let emptyItem = RIGImageGalleryItem(placeholderImage: UIImage.genericImage(.tall))
        let fullItem = RIGImageGalleryItem(image: UIImage.genericImage(.tall))

        XCTAssertTrue(RIGSingleImageViewController(viewerItem: fullItem).scrollView.allowZoom, "zoom should be enabled if loaded with an image")
        XCTAssertFalse(RIGSingleImageViewController(viewerItem: emptyItem).scrollView.allowZoom, "zoom should be disabled if loaded with a placeholder")

        let viewController = RIGSingleImageViewController()
        XCTAssertFalse(viewController.scrollView.allowZoom, "Zoom should be disabled on inital load with no content")
        viewController.viewerItem = fullItem
        XCTAssertTrue(viewController.scrollView.allowZoom, "Zoom should be enabled if a item with an image is set")
        viewController.viewerItem = emptyItem
        XCTAssertFalse(viewController.scrollView.allowZoom, "Zoom should be disabled if an image with only a placeholder is set")
        viewController.viewerItem = fullItem
        XCTAssertTrue(viewController.scrollView.allowZoom, "making sure zoom is re-enabled")
        viewController.viewerItem = nil
        XCTAssertFalse(viewController.scrollView.allowZoom, "Zoom should be disabled if the viewer item is nil'd out")
    }

}
