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
        imageGallery.viewWillAppear(false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testChangingImages() {
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
        imageGallery.setCurrentImage(0, animated: false)
        XCTAssertEqual(imageGallery.currentImage, 0, "Making sure current selected image updated")
    }

    func testDelegateAndBarButtons() {
        let completeDelegate = CompletePhotoViewControllerDelegate()
        imageGallery.photoViewDelegate = completeDelegate
        let incompleteDelegate = IncompletePhotoViewControllerDelegate()
        imageGallery.photoViewDelegate = incompleteDelegate
        let noDismissDelegate = NoDismissPhotoViewControllerDelegate()
        imageGallery.photoViewDelegate = noDismissDelegate

        imageGallery.doneButton = UIBarButtonItem()
        imageGallery.actionButton = UIBarButtonItem()

        imageGallery.actionForGalleryItem = { _ in }

        imageGallery.actionForGalleryItem = nil
    }

    func testStatusBarHidden() {
        XCTAssertFalse(imageGallery.prefersStatusBarHidden())
        imageGallery.toggleBarVisiblity(UITapGestureRecognizer())
        XCTAssertTrue(imageGallery.prefersStatusBarHidden())
    }

}

@objc private class CompletePhotoViewControllerDelegate: NSObject, RIGPhotoViewControllerDelegate {

    @objc func dismissPhotoViewer() {
    }

    @objc func showDismissForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        return true
    }

    @objc func handleGalleryIndexUpdate(newIndex: Int) {
    }
}

@objc private class NoDismissPhotoViewControllerDelegate: NSObject, RIGPhotoViewControllerDelegate {

    @objc func dismissPhotoViewer() {
    }

    @objc func showDismissForTraitCollection(traitCollection: UITraitCollection) -> Bool {
        return false
    }

    @objc func handleGalleryIndexUpdate(newIndex: Int) {
    }
}


@objc private class IncompletePhotoViewControllerDelegate: NSObject, RIGPhotoViewControllerDelegate {

    @objc func dismissPhotoViewer() {
    }

}
