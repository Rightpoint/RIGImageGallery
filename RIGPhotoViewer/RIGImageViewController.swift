//
//  RIGImageViewController.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/8/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

public class RIGImageViewController: UIViewController {

    private var needsCentering = true

    public var viewerItem: RIGPhotoViewerItem? {
        didSet {
            scrollView.zoomImage = viewerItem?.displayImage
        }
    }

    public var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil) {
        didSet {
            configureDoneButton()
        }
    }

    internal let scrollView = RIGAutoCenteringScrollView()

    public override func loadView() {
        configureDoneButton()
        automaticallyAdjustsScrollViewInsets = false
        view = scrollView
        view.backgroundColor = .blackColor()
        view.clipsToBounds = true
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = doneButton
    }

    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }

}

extension RIGImageViewController {

    func dismissPhotoView(sender: UINavigationItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

private extension RIGImageViewController {

    func configureDoneButton() {
        doneButton.target = self
        doneButton.action = "dismissPhotoView:"
    }

}