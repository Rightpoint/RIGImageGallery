//
//  RIGImageGalleryDemoUITests.swift
//  RIGImageGalleryDemoUITests
//
//  Created by Michael Skiba on 1/20/17.
//  Copyright © 2017 Raizlabs. All rights reserved.
//

import XCTest

class RIGImageGalleryDemoUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDemoReel() {
        let app = XCUIApplication()
        app.buttons["Show Local Gallery"].tap()

        let imageGallery = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element

        // 1 second delay for video recording
        Thread.sleep(forTimeInterval: 1)

        // show zoom to 1x / zoom out on the first image
        imageGallery.doubleTap()
        Thread.sleep(forTimeInterval: 0.2)
        imageGallery.doubleTap()
        Thread.sleep(forTimeInterval: 0.2)
        imageGallery.swipeLeft()

        // show hide navbar on the second image
        imageGallery.tap()
        Thread.sleep(forTimeInterval: 0.5)
        imageGallery.swipeLeft()

        // show returning the navbar on third image
        Thread.sleep(forTimeInterval: 0.5)
        imageGallery.tap()

        imageGallery.swipeLeft()

        imageGallery.pinch(withScale: 4, velocity: 5)

        imageGallery.swipeLeft()
        imageGallery.swipeLeft()

        let imageScroller = imageGallery.descendants(matching: .scrollView).element
        imageScroller.tap()
        imageScroller.pinch(withScale: 4, velocity: 5)
        imageScroller.pinch(withScale: 0.25, velocity: -1)
        imageScroller.pinch(withScale: 0.5, velocity: -1)
        imageScroller.swipeLeft()
        imageScroller.tap()

        // 1 second delay for video recording
        Thread.sleep(forTimeInterval: 1)
    }

}
