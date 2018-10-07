//
//  ImageNode.swift
//
//  Created by nangezao on 2017/7/19.
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
import Layoutable

public enum ContentMode{
  case scaleToFill
  case scaleAspectToFit
  case scaleAspectToFill
}

open class ImageNode: ControlNode {
  
  public var image: UIImage?{
    didSet{
      if image != oldValue{
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
      }
    }
  }
  
  public var processor: ImageProcessor? = nil
  
  public var contentMode: ContentMode = .scaleAspectToFill{
    didSet{
      if oldValue != contentMode{
        setNeedsDisplay()
      }
    }
  }
  
  override open var itemIntrinsicContentSize: CGSize{
    if let image = image {
      return image.size
    }
    return .zero
  }
  
  override func contentForLayer(_ layer: AsyncDisplayLayer, isCancel: () -> Bool) -> UIImage? {
    guard let image = image ,bounds.width > 0, bounds.height > 0 else{
      return nil
    }
    
    /// if image size equal to bounds and processor is nil ,no need to process image
    if image.size == bounds.size && processor == nil{
      return image
    }
    
    let key = ImageKey(image: image, size: bounds.size,contentMode: contentMode, processor: processor)
    return ImageRender.imageForKey(key, isCancelled: isCancel)
  }

}
