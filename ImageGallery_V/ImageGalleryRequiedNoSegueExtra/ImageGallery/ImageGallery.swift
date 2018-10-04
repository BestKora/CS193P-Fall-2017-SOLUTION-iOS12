//
//  ImageGallery.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 19/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import Foundation

struct ImageModel: Codable,Equatable {
    var url: URL
    var aspectRatio: Double
}

class ImageGallery: Codable {
    
    var name: String
    var images = [ImageModel]()

    init(name: String) {
        self.name = name
    }
    
    func addImage(image: ImageModel) {
        images.append(image)
    }
}
