//
//  CustomImageView.swift
//  InstagramCopy
//
//  Created by Huot on 12/5/19.
//

import UIKit

class CustomImageView: UIImageView {
    var imageCache = [String: UIImage]()
    var lastImgUrlUsedToLoadImage: String?
    
    func loadImage(with urlString: String){
        // set image to nil
        self.image = nil
        
        // set lastImageUrlToLoad
        lastImgUrlUsedToLoadImage = urlString
        
        // check if image exist in cache
        if let cachedImage = imageCache[urlString]{
            self.image = cachedImage
        }
        // if image does not extist
        
        //url for image location
        guard let url = URL(string: urlString) else { return }
        
        //fetch contents of url
        URLSession.shared.dataTask(with: url) { (data, respone, error) in
            // handle error
            if let error = error {
                print("Failed to load image...", error.localizedDescription)
            }
            
            if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            // image data
            guard let imageData = data else { return }
            
            // create image using image data
            let photoImage = UIImage(data: imageData)
            
            // set key and value for image cache
            self.imageCache[url.absoluteString] = photoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
