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

struct ImageGallery: Codable {
    var images = [ImageModel]()

    mutating func addImage(image: ImageModel) {
        images.append(image)
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
   init (){
        self.images = [ImageModel]()
    }
}

