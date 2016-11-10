//
//  TestingExtensions.swift
//  RIGImageGallery
//
//  Created by Michael Skiba on 7/12/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

extension CGSize {
    static let wide = CGSize(width: 1920, height: 1080)
    static let tall = CGSize(width: 480, height: 720)
    static let smallWide = CGSize(width: 480, height: 270)
    static let smallTall = CGSize(width: 207, height: 368)
}

extension UIImage {

    static var allGenerics: [UIImage] {
        return [UIImage.genericImage(.wide), UIImage.genericImage(.tall), UIImage.genericImage(.smallWide), UIImage.genericImage(.smallTall)]
    }

    static func genericImage(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let fillPath = UIBezierPath(rect: CGRect(origin: CGPoint(), size: size))
        fillPath.fill()
        let genericImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return genericImage!
    }

}
