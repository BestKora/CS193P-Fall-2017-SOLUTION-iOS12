//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 19/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import Foundation

struct ImageModel {
    var url: URL
    var aspectRatio: Double
}

 class ImageGallery {
    
    var name: String
    var images = [ImageModel]()

    init(name: String) {
        self.name = name
    }
}
