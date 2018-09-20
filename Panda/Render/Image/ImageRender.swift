//
//  ImageRender.swift
//  Cassowary
//
//  Created by nangezao on 2017/12/3.
//  Copyright © 2017年 nange. All rights reserved.
//
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

final class ImageRender{
  
  static let cache = NSCache<ImageKey, UIImage>()
  
  class func imageForKey(_ key: ImageKey, isCancelled: CancelBlock) -> UIImage?{
    if let image = cache.object(forKey: key){
      return image
    }
    
    if let image = contentForKey(key, isCancelled){
      cache.setObject(image, forKey: key)
      return image
    }
    
    return nil;
  }
  
  class func contentForKey(_ key: ImageKey, _ isCancelled: CancelBlock)->UIImage?{
  
    if isCancelled(){ return nil }
    
    UIGraphicsBeginImageContextWithOptions(key.size, false, UIScreen.main.scale)
    defer { UIGraphicsEndImageContext() }
    
    var size: CGSize = .zero
    switch key.contentMode {
    case .scaleAspectToFit: size = key.image.size.fitted(to: key.size)
    case .scaleAspectToFill: size = key.image.size.filling(with: key.size)
    case .scaleToFill: size = key.size
    }
    let origin = size.inset(to: key.size)
    
    if isCancelled(){ return nil }
    
    key.image.draw(in: CGRect(origin: origin, size: size))
    
    if isCancelled(){ return nil }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    if let processor = key.processor,let image = image{
      return processor.process(image: image)
    }
    return image
  }
  
}

final class ImageKey: NSObject {
  let image: UIImage
  let size: CGSize
  let contentMode: ContentMode

  var processor: ImageProcessor? = nil
  let hashCache: Int
  
  init(image: UIImage, size: CGSize, contentMode: ContentMode = .scaleAspectToFill ,processor: ImageProcessor? = nil) {
    self.image = image
    self.size = size
    self.processor = processor
    self.contentMode = contentMode
    
    var hasher = Hasher()
    hasher.combine(image)
    hasher.combine(size)
    hasher.combine(contentMode)
    hashCache = hasher.finalize()
  }
  
  override var hash: Int{
    return hashCache
  }
  
  override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? ImageKey else{
      return false
    }
    return size == object.size && image == object.image
  }
}
