//
//  RIGImageGalleryItem.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

public struct RIGImageGalleryItem: Equatable {

    public var image: UIImage?
    public var placeholderImage: UIImage?
    public var title: String?

    public init(image: UIImage? = nil, placeholderImage: UIImage? = nil, title: String? = nil) {
        self.image = image
        self.placeholderImage = placeholderImage
        self.title = title
    }

}

public func == (lhs: RIGImageGalleryItem, rhs: RIGImageGalleryItem) -> Bool {
    return lhs.image === rhs.image && lhs.placeholderImage === rhs.placeholderImage && lhs.title == rhs.title
}
