//
//  RIGImageGalleryTestAutoCenteringScrollView.swift
//  RIGImageGalleryTests
//
//  Created by Michael Skiba on 7/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import XCTest
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
        scrollView.baseInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    }
    
}
