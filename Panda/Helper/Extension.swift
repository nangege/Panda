//
//  Extension.swift
//  Panda
//
//  Created by nangezao on 2018/9/14.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Foundation

extension CGSize{
  /// scale self and keep aspectRatio to fite size
  public func fitted(to size: CGSize) -> CGSize {
    let aspectWidth = round(aspectRatio * size.height)
    let aspectHeight = round(size.width / aspectRatio)
    
    return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
  }
  
  /// scale self keep aspectRatio to fill size
  public func filling(with size: CGSize) -> CGSize {
    let aspectWidth = round(aspectRatio * size.height)
    let aspectHeight = round(size.width / aspectRatio)
    
    return aspectWidth < size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
  }
  
  func constrainted(to size: CGSize) -> CGSize{
    return CGSize(width: min(width, size.width),
                  height: min(height, size.height))
  }
  
  public func inset(to size: CGSize) -> CGPoint{
    return CGPoint(x: (size.width - width)/2 ,
                   y: (size.height - height)/2)
  }
  
  private var aspectRatio: CGFloat {
    return height == 0.0 ? 1.0 : width / height
  }
}

extension CGRect{
  
  /// layout two item with size lhs and rhs horizontal, equal centerX
  ///
  /// - Parameters:
  ///   - lhs: item in left
  ///   - rhs: item in right
  ///   - space: space between lhs and rhs item
  /// - Returns: rect for lhs and rhs item
  func constraint(lhs: CGSize, rhs: CGSize,space: CGFloat) -> (CGRect, CGRect){
    let contentSize = lhs.combineTo(rhs, space: space, isVertical: false)
    let x = (size.width - contentSize.width)/2
    let y = (height - lhs.height)/2
    
    var lhsRect = CGRect(origin: CGPoint(x: x, y: y), size: lhs)
    
    let minX = lhsRect.maxX + space
    let w = width - minX
    
    let rhsY = (height - rhs.height)/2
    var rhsRect = CGRect(x: minX, y: rhsY, width: min(w, rhs.width), height: rhs.height)
    
    if rhs.width == 0{
      lhsRect = lhsRect.offsetBy(dx: space, dy: 0)
    }else if lhs.width == 0{
      rhsRect = rhsRect.offsetBy(dx: -space, dy: 0)
    }
    return (lhsRect.pixelRounded, rhsRect.pixelRounded)
  }
  
  /// layout two item with size ths and bhs vertical , equal centerY
  ///
  /// - Parameters:
  ///   - ths: item in top
  ///   - bhs: item in bottom
  ///   - space: space between ths and bhs item
  /// - Returns: rect for ths and bhs item
  func constraint(ths: CGSize, bhs: CGSize, space: CGFloat) -> (CGRect, CGRect){
    let contentSize = ths.combineTo(bhs, space: space, isVertical: true)
    let x = (width - ths.width)/2
    let y = (height - contentSize.height)/2
    let thsRect = CGRect(origin: CGPoint(x: x, y: y), size: ths)
    
    let minY = thsRect.maxY + space
    let h = height - minY
    let maxY = max(h,0)
    
    let bhsX = (width - bhs.width)/2
    let bhsRect = CGRect(x: bhsX, y: minY, width: bhs.width, height: maxY)
    return (thsRect.pixelRounded, bhsRect.pixelRounded)
  }
  
}

extension CGSize{
  
  /// caculate the best size to hold two size
  ///
  /// - Parameters:
  ///   - other: another size to contain
  ///   - space: space between two item
  ///   - isVertical: layout vertical or horizontal
  /// - Returns: the best size to hold self and other size
  func combineTo(_ other: CGSize,space: CGFloat,isVertical: Bool = false) -> CGSize{
    var size = CGSize.zero
    if !isVertical{
      size.width = width + space + other.width
      size.height = max(height,other.height)
      
      if width == 0 || other.width == 0{
        size.width -= space
      }
    }else{
      size.width = max( width, other.width)
      size.height = height + space + other.height
      
      if height == 0 || other.height == 0{
        size.height -= space
      }
    }
    return size
  }
}

extension CGFloat{
  
  /// adjust to fit pixel
  var pixelRounded: CGFloat{
    let scale = UIScreen.main.scale
    return ceil(self*scale)/scale
  }
}

extension CGRect{
  
  /// adjust to fit pixel
  var pixelRounded: CGRect{
    return CGRect(x: minX.pixelRounded,
                  y: minY.pixelRounded,
              width: width.pixelRounded,
             height: height.pixelRounded)
  }
}



