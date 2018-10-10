//
//  ViewLayout.swift
//  PandaDemo
//
//  Created by nangezao on 2018/9/2.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import UIKit
import Layoutable

extension UIView: Layoutable{
  struct Key {
    static var LayoutManager = "LayoutManager"
  }
  
  public var layoutRect: CGRect{
    set{ frame = layoutRect }
    get{ return frame }
  }
  
  public var layoutManager: LayoutManager {
    get{
      if let m = objc_getAssociatedObject(self, &Key.LayoutManager) as? LayoutManager{
        return m
      }
      let manager = LayoutManager(self)
      self.layoutManager = manager
      return manager
    }
    set { objc_setAssociatedObject(self, &Key.LayoutManager, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
  }
  
  public var superItem: Layoutable? {
    return superview
  }
  
  public var subItems: [Layoutable] {
    return subviews
  }
  
  public func layoutSubItems() {
    layoutSubviews()
  }
  
  public func updateConstraint() {}
  
  public func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    return InvaidIntrinsicSize
  }
  
  public var itemIntrinsicContentSize: CGSize {
    return InvaidIntrinsicSize
  }
}

extension CALayer: Layoutable{

  struct Key {
    static var LayoutManager = "LayoutManager"
  }
  
  public var layoutManager: LayoutManager {
    get{
      if let m = objc_getAssociatedObject(self, &Key.LayoutManager) as? LayoutManager{
        return m
      }
      let manager = LayoutManager(self)
      self.layoutManager = manager
      return manager
    }
    set { objc_setAssociatedObject(self, &Key.LayoutManager, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
  }
  
  public var superItem: Layoutable? {
    return superlayer
  }
  
  public var subItems: [Layoutable] {
    return sublayers ?? [CALayer]()
  }
  
  public func layoutSubItems() {
    layoutSublayers()
  }
  
  public var layoutRect: CGRect{
    set{
      frame = layoutRect.pixelRounded
    }
    
    get{
      return frame
    }
  }
  
  public func updateConstraint() {}
  
  public func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    return InvaidIntrinsicSize
  }
  
  public var itemIntrinsicContentSize: CGSize{
    return InvaidIntrinsicSize
  }
}

