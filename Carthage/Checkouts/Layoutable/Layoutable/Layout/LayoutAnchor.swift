//
//  LayoutAnchor.swift
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
import Cassowary

public protocol AnchorType{
  
  var item: Layoutable!{ get set}
  
  var attribute: LayoutAttribute{ get }
}

extension AnchorType{
  func expression() -> Expression{
    return item.manager.variable.expressionFor(attribue: attribute)
  }
  
  func expression(in node: Layoutable?) -> Expression{
    let expr = expression()
    guard let node = node else {
      return expr
    }
    
    expr.earse(node.manager.variable.x)
    expr.earse(node.manager.variable.y)
    
    if node === item {
      return expr
    }
    
    assert(item.superItem != nil)
    var superItem = item.superItem!
    let xExpr = Expression()
    let yExpr = Expression()
    while !(superItem === node)  {
      xExpr += superItem.manager.variable.x
      yExpr += superItem.manager.variable.y
      assert(superItem.superItem != nil)
      superItem = superItem.superItem!
    }
    let coffeeX = expr.coefficient(for: item.manager.variable.x)
    let coffeeY = expr.coefficient(for: item.manager.variable.y)
    expr += coffeeX * xExpr
    expr += coffeeY * yExpr
    return expr
  }
}

extension AnchorType{
  
  @discardableResult public func constraint(to anchor: Self? = nil,relation: LayoutRelation, constant: CGFloat = 0) -> LayoutConstraint{
    return LayoutConstraint(firstAnchor: self , secondAnchor: anchor, relation: relation, constant:constant)
  }
  
  // These methods return a constraint of the form thisAnchor = otherAnchor + constant.
  @discardableResult public func equalTo(_ anchor: Self? = nil, constant: CGFloat = 0) -> LayoutConstraint{
    return constraint(to: anchor, relation: .equal, constant: constant)
  }
  
  @discardableResult public func greaterThanOrEqualTo(_ anchor: Self? = nil, constant: CGFloat = 0) -> LayoutConstraint{
    return constraint(to: anchor, relation: .greatThanOrEqual, constant: constant)
  }
  
  @discardableResult public func lessThanOrEqualTo(_ anchor: Self? = nil, constant: CGFloat = 0) -> LayoutConstraint{
    return constraint(to: anchor, relation: .lessThanOrEqual, constant: constant)
  }
  
  @discardableResult static public func == (lhs: Self, rhs: Self) -> LayoutConstraint{
    return lhs.equalTo(rhs)
  }
  
  @discardableResult static public func <= (lhs: Self, rhs: Self) -> LayoutConstraint{
    return lhs.lessThanOrEqualTo(rhs)
  }
  
  @discardableResult static public func >= (lhs: Self,rhs: Self) -> LayoutConstraint{
    return lhs.greaterThanOrEqualTo(rhs)
  }
  
  @discardableResult static public func == (lhs: Self, rhs: CGFloat) -> LayoutConstraint{
    return lhs.equalTo(constant: rhs)
  }
  
  @discardableResult static public func <= (lhs: Self, rhs: CGFloat) -> LayoutConstraint{
    return lhs.lessThanOrEqualTo(constant: rhs)
  }
  
  @discardableResult static public func >= (lhs: Self,rhs: CGFloat) -> LayoutConstraint{
    return lhs.greaterThanOrEqualTo(constant: rhs)
  }
}

public class Anchor: AnchorType{
  
  public weak var item: Layoutable!
    
  public let attribute: LayoutAttribute
    
  public init(item: Layoutable, attribute: LayoutAttribute){
    self.item = item
    self.attribute = attribute
  }
}

/// Axis-specific subclasses for location anchors: top/bottom, left/right, etc.
final public class XAxisAnchor : Anchor {}

final public  class YAxisAnchor : Anchor {}

/// This layout anchor subclass is used for sizes (width & height).
final public class DimensionAnchor : Anchor {

  ///  These methods return a constraint of the form
  ///  thisAnchor = otherAnchor * multiplier + constant.
  @discardableResult final public func equalTo(_ anchor: DimensionAnchor? = nil, multiplier m: CGFloat = 1, constant: CGFloat = 0) -> LayoutConstraint{
    return LayoutConstraint(firstAnchor: self, secondAnchor: anchor, relation: .equal, multiplier: m, constant: constant)
  }

  @discardableResult final public func greaterThanOrEqualTo(_ anchor: DimensionAnchor? = nil, multiplier m: CGFloat = 1, constant: CGFloat = 0 ) -> LayoutConstraint{
    return LayoutConstraint(firstAnchor:self, secondAnchor: anchor, relation:.greatThanOrEqual ,multiplier:m, constant:constant )
  }

  @discardableResult final public func lessThanOrEqualTo(_ anchor: DimensionAnchor? = nil, multiplier m: CGFloat = 1, constant: CGFloat = 0) -> LayoutConstraint{
      return LayoutConstraint(firstAnchor:self, secondAnchor: anchor,relation:.lessThanOrEqual ,multiplier:m, constant:constant )
  }
}

final public class LayoutExpression<AnchorType: Anchor>{
  var anchor: AnchorType
  var value: CGFloat
  var multiplier: CGFloat = 1
  
  init(anchor: AnchorType, multiplier: CGFloat = 1, offset: CGFloat = 0) {
    self.anchor = anchor
    self.multiplier = multiplier
    self.value = offset
  }
}

@discardableResult public func + <AnchorType: Anchor>(lhs: AnchorType, rhs: CGFloat) -> LayoutExpression<AnchorType>{
  return LayoutExpression(anchor: lhs, offset: rhs)
}

@discardableResult public func - <AnchorType: Anchor>(lhs: AnchorType, rhs: CGFloat) -> LayoutExpression<AnchorType>{
  return lhs + (-rhs)
}

@discardableResult public func == <AnchorType: Anchor>(lhs: AnchorType, rhs: LayoutExpression<AnchorType>) -> LayoutConstraint{
  return lhs.equalTo(rhs.anchor, constant: rhs.value)
}

@discardableResult public func >= <AnchorType: Anchor>(lhs: AnchorType, rhs: LayoutExpression<AnchorType>) -> LayoutConstraint{
  return lhs.greaterThanOrEqualTo(rhs.anchor, constant: rhs.value)
}

@discardableResult public func <= <AnchorType: Anchor>(lhs: AnchorType, rhs: LayoutExpression<AnchorType>) -> LayoutConstraint{
  return lhs.lessThanOrEqualTo(rhs.anchor, constant: rhs.value)
}

/// LayoutDimession
@discardableResult public func + <AnchorType: Anchor>(lhs: LayoutExpression<AnchorType>, rhs: CGFloat) -> LayoutExpression<AnchorType>{
  lhs.value += rhs
  return lhs
}

@discardableResult public func - (lhs: LayoutExpression<DimensionAnchor>, rhs: CGFloat) -> LayoutExpression<DimensionAnchor>{
  return lhs + (-rhs)
}

@discardableResult public func * (lhs: DimensionAnchor, rhs: CGFloat) -> LayoutExpression<DimensionAnchor>{
  return LayoutExpression(anchor: lhs, multiplier: rhs)
}

@discardableResult public func / (lhs: DimensionAnchor, rhs: CGFloat) -> LayoutExpression<DimensionAnchor>{
  return lhs * (1/rhs)
}

@discardableResult public func == (lhs: DimensionAnchor, rhs: LayoutExpression<DimensionAnchor>) -> LayoutConstraint{
  return lhs.equalTo(rhs.anchor, multiplier: rhs.multiplier, constant: rhs.value)
}

@discardableResult public func >= (lhs: DimensionAnchor, rhs: LayoutExpression<DimensionAnchor>) -> LayoutConstraint{
  return lhs.greaterThanOrEqualTo(rhs.anchor, multiplier: rhs.multiplier, constant: rhs.value)
}

@discardableResult public func <= (lhs: DimensionAnchor, rhs: LayoutExpression<DimensionAnchor>) -> LayoutConstraint{
  return lhs.lessThanOrEqualTo( rhs.anchor, multiplier: rhs.multiplier, constant: rhs.value)
}

