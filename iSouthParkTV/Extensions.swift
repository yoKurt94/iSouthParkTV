//
//  Extensions.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import UIKit

class Extensions {
}

let imageCache = NSCache<AnyObject, AnyObject>()

class LazyLoadingImage: UIImageView {
    
    var imageURLString: String?
    
    func loadImageUsingURLString(urlString: String, completion: @escaping ((UIImage) -> Void)) {
        let url = URL(string: urlString)
        imageURLString = urlString
        self.image = nil
        if let alreadyCachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = alreadyCachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if error != nil {
                print(error?.localizedDescription)
            }
            guard let data = data else {
                return
            }

            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data)
                if self.imageURLString == urlString {
                    completion(imageToCache!)
                }
                imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            }
        }.resume()
    }
}
