//
//  ImageProcessor.swift
//  Panda
//
//  Created by nangezao on 2018/9/13.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol ImageProcessor {
  func process(image: UIImage) -> UIImage
}

public struct RoundImageProcessor: ImageProcessor {
  
  public init(radius: CGFloat) {
    self.cornerRadius = radius
  }
  
  private var cornerRadius: CGFloat
  
  public func process(image: UIImage) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    guard let context = UIGraphicsGetCurrentContext() else{
      return image
    }
    
    let rect = CGRect(origin: .zero, size: image.size)
    let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
    path.close()
    context.saveGState()
    path.addClip()
    image.draw(in: rect)
    context.restoreGState()
    return UIGraphicsGetImageFromCurrentImageContext() ?? image
  }
}
