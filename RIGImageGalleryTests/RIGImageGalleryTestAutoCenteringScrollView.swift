//
//  RIGImageGalleryTestAutoCenteringScrollView.swift
//  RIGImageGalleryTests
//
//  Created by Michael Skiba on 7/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
import UIKit
@testable import RIGImageGallery

class RIGImageGalleryTests: XCTestCase {

    var scrollView = RIGAutoCenteringScrollView(frame: CGRect())
    
    override func setUp() {
        super.setUp()
        scrollView = RIGAutoCenteringScrollView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSettingInsets() {
        XCTAssertEqual(scrollView.zoomScale, 1, "The scroll view's zoom scale should start at 1")
        XCTAssertEqual(scrollView.minimumZoomScale, 1, "The scroll view's min zoom scale should start at 1")
        XCTAssertEqual(scrollView.maximumZoomScale, 1, "The scroll view's max zoom scale should start at 1")
        let targetInsets = UIEdgeInsets(top: 25, left: 50, bottom: 25, right: 50)
        scrollView.baseInsets = targetInsets
        XCTAssert(UIEdgeInsetsEqualToEdgeInsets(scrollView.baseInsets, targetInsets), "Base insets should equal the value they're set to")
        XCTAssertEqual(scrollView.zoomScale, 1, "With no image, the scrollview's zoom scale should still equal 1")
        let image = UIImage.genericImage(.wideSize)
        scrollView.zoomImage = image
        // double setting to get code coverage on the short circuit for not doing any work when setting the same image
        scrollView.zoomImage = image
        XCTAssertEqualWithAccuracy(scrollView.minimumZoomScale, (400.0 - 50.0 - 50.0) / 1920, accuracy: 0.0001, "min zoom scale is should equal the width minus insets divided by image width")
        scrollView.zoomImage = UIImage.genericImage(.tallSize)
        XCTAssertEqualWithAccuracy(scrollView.minimumZoomScale, (400.0 - 25.0 - 25.0) / 720.0, accuracy: 0.0001, "Scoll view's min scroll view should equal the height minus insets divied be image height for taller images")
        scrollView.baseInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        XCTAssertEqualWithAccuracy(scrollView.minimumZoomScale, 400.0 / 720.0, accuracy: 0.0001, "Scoll view's min scroll view should equal the height minus insets divied be image height for taller images")
                scrollView.zoomImage = nil
    }

    func testCentering() {
    }
    
}

extension CGSize {
    static let wideSize = CGSize(width: 1920, height: 1080)
    static let tallSize = CGSize(width: 480, height: 720)
}

extension UIImage {

    static func genericImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let fillPath = UIBezierPath(rect: CGRect(origin: CGPoint(), size: size))
        fillPath.fill()
        let genericImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return genericImage
    }

}
