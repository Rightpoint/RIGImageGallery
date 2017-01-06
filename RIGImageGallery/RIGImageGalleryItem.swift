//
//  RIGImageGalleryItem.swift
//  RIGPhotoViewer
//
//  Created by Michael Skiba on 2/9/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

import UIKit

/**
 *  RIGImageGalleryItem stores an image, placeholder Image, and title to associate with each image
 */
public struct RIGImageGalleryItem: Equatable {

    /// The image to display
    public var image: UIImage?
    /// A placeholder image to display if the display image is nil or becomes nil
    public var placeholderImage: UIImage?
    /// The title of the image
    public var title: String?
    // The loading state
    public var isLoading: Bool

    public init(image: UIImage? = nil, placeholderImage: UIImage? = nil, title: String? = nil, isLoading: Bool = false) {
        self.image = image
        self.placeholderImage = placeholderImage
        self.title = title
        self.isLoading = isLoading
    }

}

public func == (lhs: RIGImageGalleryItem, rhs: RIGImageGalleryItem) -> Bool {
    return lhs.image === rhs.image && lhs.placeholderImage === rhs.placeholderImage && lhs.title == rhs.title
}
