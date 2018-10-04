//
//  ImageCollectionViewCell.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 20/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit
//let cache =  URLCache.shared
let cache = URLCache(
    memoryCapacity: 5*1024*1024,
    diskCapacity: 30*1024*1024,
    diskPath: nil)

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageGallery: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var imageURL: URL? {
        didSet { updateUI()}
    }
    
    
    var changeAspectRatio : (() -> Void)?
    
    private func updateUI() {
        guard let url = imageURL else {return}
        imageGallery.image = nil
        let request = URLRequest(url: url)
        self.spinner?.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                //    self.imageGallery?.image =  image
                    self.imageGallery?.transition(toImage: image)
                    print ("кэш")
                    self.spinner?.stopAnimating()
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler:
                    { (data, response, error) in
                    if let data = data,
                        let response = response,
                        ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300,
                        let image = UIImage(data: data),
                        url == self.imageURL {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        DispatchQueue.main.async {
                            self.imageGallery?.image =  image
                            print ("сеть")
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.spinner?.stopAnimating()
                            self.imageGallery?.image =
                                "Error 😡".emojiToImage()?.applyBlurEffect()
                            self.changeAspectRatio?()
                            
                        }
                    }
                }).resume()
            }
        }
        spinner?.stopAnimating()
    }
}

extension String {
    func emojiToImage() -> UIImage? {
        let size = CGSize(width: 160 , height: 160)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        #colorLiteral(red: 0.7368795971, green: 0.9366820587, blue: 0.9764705896, alpha: 0.7592037671).set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect,
                                withAttributes: [
                                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)
            ]
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {
    func applyBlurEffect()-> UIImage {
        let imageToBlur = CIImage(image: self)
        let filter =  CIFilter(name: "CIGaussianBlur")
        filter?.setValue(imageToBlur, forKey: "inputImage")
        filter?.setValue(5, forKey: "inputRadius")
        let resultImage = filter?.value(forKey: "outputImage") as? CIImage
        let blurredImage = UIImage(ciImage: resultImage!)
        
        return blurredImage
    }
}

extension UIImageView {
    func transition(toImage image: UIImage?) {
        UIView.transition(with: self, duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.image = image
        },
                          completion: nil)
    }
}

// self.imageGallery?.transition(toImage: image)

/*          DispatchQueue.global(qos: .userInitiated).async {
 let urlContents = try? Data(contentsOf: url)
 
 DispatchQueue.main.async {
 if let imageData = urlContents, url == self.imageURL,
 let image = UIImage(data: imageData) {
 self.imageGallery?.image =  image
 } else {
 self.imageGallery?.image =
 "Error 😡".emojiToImage()?.applyBlurEffect()
 self.changeAspectRatio?()
 }
 self.spinner?.stopAnimating()
 }
 } */
