//
//  CompositAnchor.swift
//  Layout
//
//  Created by nangezao on 2018/8/24.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Foundation

// use tuple as data struct to make it easy to write
// like node.size = (30,30) compare to UIKit node.size = CGSize(width: height: 30)
public typealias Size = (width: CGFloat, height: CGFloat)
public typealias Offset = (x: CGFloat, y: CGFloat)
public typealias Insets = (top: CGFloat,left: CGFloat, bottom: CGFloat,right: CGFloat)
public typealias XSideInsets = (left: CGFloat, right: CGFloat)
public typealias YSideInsets = (top: CGFloat, bottom: CGFloat)
public typealias EdgeInsets = (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)

public let EdgeInsetsZero: EdgeInsets = (0,0,0,0)

public enum LayoutAxis{
  case horizontal
  case vertical
}

public class CompositAnchor{
  let item: Layoutable
  
  public init(item: Layoutable) {
    self.item = item
  }
}

final public class SizeAnchor: CompositAnchor{
  @discardableResult public func equalTo(_ size: Size) -> [LayoutConstraint]{
    return [
      item.width == size.width,
      item.height == size.height
    ]
  }
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, offset: Offset = ( 0, 0)) -> [LayoutConstraint]{
    return [
      item.width == layoutItem.width + offset.x,
      item.height == layoutItem.height + offset.y
    ]
  }
  
  @discardableResult public static func == (lhs: SizeAnchor, rhs: Size) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
}

typealias PositionAttributes = (x: LayoutAttribute, y: LayoutAttribute)

final public class PositionAnchor: CompositAnchor{
  
  let attributes: PositionAttributes
  
  init(item: Layoutable, attributes: PositionAttributes) {
    self.attributes = attributes
    super.init(item: item)
  }
  
  public func offset(_ offset: Offset) -> CompositExpression<PositionAnchor, Offset>{
    return self + offset
  }
  
  @discardableResult public func equalTo(_ anchor: PositionAnchor, offset: Offset = (0,0)) -> [LayoutConstraint]{
    
    let x = XAxisAnchor(item: item,
                        attribute: attributes.x) ==
      XAxisAnchor(item: anchor.item,
                  attribute: anchor.attributes.x) + offset.x
    
    let y = YAxisAnchor(item: item,
                        attribute: attributes.y) ==
      YAxisAnchor(item: anchor.item,
                  attribute: anchor.attributes.y) + offset.y
    
    return [x,y]
  }
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, offset: Offset = (0,0)) -> [LayoutConstraint]{
    return equalTo(PositionAnchor(item: layoutItem, attributes: attributes),
                   offset: offset)
  }
  
  @discardableResult static public func == (lhs: PositionAnchor, rhs: Layoutable) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
  
  @discardableResult static public func == (lhs: PositionAnchor, rhs: PositionAnchor) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
}

final public class XSideAnchor: CompositAnchor{
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, insets: XSideInsets  = (0,0)) -> [LayoutConstraint]{
    return [
      item.left == layoutItem.left + insets.left,
      item.right == layoutItem.right - insets.right
    ]
  }
  
  @discardableResult public func equalTo(_ anchor: XSideAnchor, insets: XSideInsets  = (0,0)) -> [LayoutConstraint]{
    return equalTo(anchor.item, insets: insets)
  }
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, insets: CGFloat) -> [LayoutConstraint]{
    return equalTo(layoutItem, insets: (insets, insets))
  }
  
  public func insets(_ inset: XSideInsets) -> CompositExpression<XSideAnchor, XSideInsets>{
    return self + inset
  }
  
  public func insets(_ inset: CGFloat) -> CompositExpression<XSideAnchor, CGFloat>{
    return self + inset
  }
  
  @discardableResult static public func == (lhs: XSideAnchor, rhs: Layoutable) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
  
}

final public class YSideAnchor: CompositAnchor{
  @discardableResult public func equalTo(_ layoutItem: Layoutable, insets: YSideInsets = (0, 0))  -> [LayoutConstraint]{
    return [
      item.top == layoutItem.top + insets.top,
      item.bottom == layoutItem.bottom - insets.bottom
    ]
  }
  
  @discardableResult public func equalTo(_ anchor: YSideAnchor, insets: YSideInsets = (0, 0))  -> [LayoutConstraint]{
    return equalTo(anchor.item, insets: insets)
  }
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, insets: CGFloat) -> [LayoutConstraint]{
    return equalTo(layoutItem, insets: (insets, insets))
  }
  
  public func insets(_ inset: YSideInsets) -> CompositExpression<YSideAnchor, YSideInsets>{
    return self + inset
  }
  
  public func insets(_ inset: CGFloat) -> CompositExpression<YSideAnchor, CGFloat>{
    return self + inset
  }

  @discardableResult static public func == (lhs: YSideAnchor, rhs: Layoutable) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
}

final public class EdgeAnchor: CompositAnchor{
  
  public func insets(_ insets: EdgeInsets) -> CompositExpression<EdgeAnchor, EdgeInsets>{
    return self + insets
  }
  
  @discardableResult public func equalTo(_ layoutItem: Layoutable, insets: EdgeInsets = EdgeInsetsZero) -> [LayoutConstraint]{
    return [
      item.top == layoutItem.top + insets.top,
      item.left == layoutItem.left + insets.left,
      item.bottom == layoutItem.bottom - insets.bottom,
      item.right == layoutItem.right - insets.right
    ]
  }
  
  @discardableResult static public func == (lhs: EdgeAnchor, rhs: Layoutable) -> [LayoutConstraint]{
    return lhs.equalTo(rhs)
  }
}

final public class CompositExpression<AnchorType, valueType>{
  var anchor: AnchorType
  var value: valueType
  
  init(anchor: AnchorType, value: valueType) {
    self.anchor = anchor
    self.value = value
  }
}

@discardableResult public func + <ValueType>(lhs: Layoutable, rhs: ValueType) -> CompositExpression<Layoutable, ValueType> {
  return CompositExpression(anchor: lhs, value: rhs)
}

@discardableResult public func + <AnchorType: CompositAnchor, ValueType>(lhs: AnchorType, rhs: ValueType) -> CompositExpression<AnchorType, ValueType> {
  return CompositExpression(anchor: lhs, value: rhs)
}

@discardableResult public func == (lhs: SizeAnchor, rhs: CompositExpression<Layoutable, Offset
  >) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, offset: rhs.value)
}

@discardableResult public func == (lhs: PositionAnchor, rhs: CompositExpression<Layoutable,Offset>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, offset: rhs.value)
}

@discardableResult public func == (lhs: PositionAnchor, rhs: CompositExpression<PositionAnchor,Offset>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, offset: rhs.value)
}

@discardableResult public func == (lhs: XSideAnchor, rhs: CompositExpression<Layoutable, CGFloat>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: XSideAnchor, rhs: CompositExpression<Layoutable, XSideInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: XSideAnchor, rhs: CompositExpression<XSideAnchor, CGFloat>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor.item, insets: rhs.value)
}

@discardableResult public func == (lhs: XSideAnchor, rhs: CompositExpression<XSideAnchor, XSideInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: YSideAnchor, rhs: CompositExpression<Layoutable, CGFloat>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: YSideAnchor, rhs: CompositExpression<Layoutable, YSideInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: YSideAnchor, rhs: CompositExpression<YSideAnchor, CGFloat>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor.item, insets: rhs.value)
}

@discardableResult public func == (lhs: YSideAnchor, rhs: CompositExpression<YSideAnchor, YSideInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: EdgeAnchor, rhs: CompositExpression<Layoutable, EdgeInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor, insets: rhs.value)
}

@discardableResult public func == (lhs: EdgeAnchor, rhs: CompositExpression<EdgeAnchor, EdgeInsets>) -> [LayoutConstraint]{
  return lhs.equalTo(rhs.anchor.item, insets: rhs.value)
}

public extension Array where Element == Layoutable{
  
  public typealias LayoutAction = (_ pre: Layoutable, _ current: Layoutable) -> (LayoutConstraint)
  
  @discardableResult func traverse(action: LayoutAction) -> [LayoutConstraint]{
    var constraints = [LayoutConstraint]()
    if count <= 1{
      return constraints
    }
    var preItem = self.first!
    for item in self{
      if item !== preItem{
        constraints.append(action(preItem, item))
      }
      preItem = item
    }
    return constraints
  }
  
  @discardableResult func space(_ space: CGFloat,axis: LayoutAxis = .vertical) -> [LayoutConstraint]{
    return traverse { (preItem, currentItem) -> (LayoutConstraint) in
      switch axis{
      case .horizontal: return currentItem.left == preItem.right + space
      case .vertical: return currentItem.top == preItem.bottom + space
      }
    }
  }
  
  @discardableResult func equal(_ attributes: LayoutAttribute...) -> [LayoutConstraint]{
    var constraints = [LayoutConstraint]()
    for attribute in attributes{
      constraints.append(contentsOf:traverse { (preItem, current) -> (LayoutConstraint) in
        let firstAnchor = Anchor(item: current, attribute: attribute)
        let secondAnchor = Anchor(item: preItem, attribute: attribute)
        return firstAnchor.equalTo(secondAnchor)
      } )
    }
    return constraints
  }
  
}


