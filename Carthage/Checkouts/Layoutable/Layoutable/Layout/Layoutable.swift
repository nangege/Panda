//
//  ConstraintAble.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/4/2.
//  Copyright © 2018年 nange. All rights reserved.
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

/// abstraction for constraint layout Item
/// any object conform to Layoutable can use constraint to caculate frame
public protocol Layoutable: class{

  var manager: LayoutManager{ get }
  
  /// contentSize of node like,just like the one in UIKit
  var intrinsicContentSize: CGSize { get }
  var superItem: Layoutable? { get }
  var subItems: [Layoutable]{ get }
  var frame: CGRect { get set}
  
  /// like layoutSubviews in UIView
  /// this method will be called after layout pass
  /// frame of LayoutItem is determined
  func layoutSubnode()
  
  /// override point.
  func updateConstraint()
  
  /// contentSize of node, unlike intrinsicContentSize, this time width of node is determined
  /// this method is used to adjust height of node
  /// like textNode, if numberOfLines is 0, we need maxWidth to determine number of lines and text height
  /// - Parameter maxWidth: maxWidth of this node
  /// - Returns: size of content
  func contentSizeFor(maxWidth: CGFloat) -> CGSize
}

extension Layoutable{
  public func addConstraint(_ constraint: LayoutConstraint){
    manager.addConstraint(constraint)
  }
  
  public func removeConstraint(_ constraint: LayoutConstraint){
    manager.removeConstraint(constraint)
  }
  
  public func removeConstraints(_ constraints: [LayoutConstraint]){
    constraints.forEach {
      self.removeConstraint($0)
    }
  }
  
  /// the caculated frame of this layout item
  public var layoutRect: CGRect {
    return manager.layoutRect
  }
  
  public var allConstraints: [LayoutConstraint]{
    return manager.constraints
  }
  
  /// disable cassowary Layout Enginer
  /// - Parameter disable: if set to true, all cassowary relate code will return immediately
  /// it is useful when you want to use cached frame to Layout node, rather than caculate again
  public func disableLayout(_ disable: Bool = true){
    manager.enabled = !disable
    subItems.forEach{ $0.disableLayout(disable)}
  }
  
  /// just like layutIfNeeded in UIView
  /// call this method will caculate and update frame immediately
  public func layoutIfEnabled(){
    
    if !manager.enabled{
      return
    }
    
    let item = ancestorItem
    
    if item.manager.solver == nil{
      let solver = LayoutEngine.solveFor(item)
      item.addConstraintTo(solver)
      try? solver.solve()
      solver.autoSolve = true
    }
    item.layoutFirstPass()
    item.layoutSecondPass()
    updateLayout()
  }
  
  
  /// layout info of the current node hierarchy
  /// provide for case of layout cache
  public var layoutValues: LayoutValues{
    var cache = LayoutValues()
    if manager.enabled && !manager.translateRectIntoConstraints{
      cache.frame = layoutRect
    }else{
      cache.frame = frame
    }
    cache.subLayout = subItems.map{ $0.layoutValues }
    return cache
  }
  
  
  /// layout node hierarchy with frame
  ///
  /// - Parameter layout: layout hierarchy from this root node
  /// - make sure node hierarchy is exactly the same when you get this layoutValues
  public func apply(_ layout: LayoutValues){

    frame = layout.frame
    for (index, node) in subItems.enumerated(){
      node.apply(layout.subLayout[index])
    }
  }
  
  func updateLayout(){
    // need to be optimized
    if manager.solver != nil && !manager.translateRectIntoConstraints{
      frame = layoutRect
    }
    subItems.forEach{ $0.updateLayout() }
  }
  
  private func addConstraintTo(_ solver: SimplexSolver){
    manager.addConstraintTo(solver)
    subItems.forEach { $0.addConstraintTo(solver) }
  }
  
  private func updateContentSize(){
    if manager.translateRectIntoConstraints{
      return
    }
    let size = intrinsicContentSize
    manager.updateSize(size, node: self)
  }
  
  private var ancestorItem: Layoutable{
    if let superItem = superItem{
      return superItem.ancestorItem
    }
    return self
  }
  
  private func updateAllConstraint(){
    updateConstraint()
    manager.updateConstraint()
  }
  
  private func layoutFirstPass(){
    if manager.layoutNeedsUpdate{
      updateContentSize()
    }else if manager.translateRectIntoConstraints && manager.pinedCount > 0{
      manager.updateSize(frame.size, node: self, priority: .required)
      manager.updateOrigin(frame.origin, node: self)
      
      /// a little weird here, when update size or origin,some constraints will be add to this item
      /// this item's translateRectIntoConstraints will be set to false
      /// correct it here. need a better way.
      manager.translateRectIntoConstraints = true
    }
    updateAllConstraint()
    subItems.forEach { $0.layoutFirstPass() }
  }
  
  /// second layout pass is used to adjust contentSize height
  /// such as TextNode,at this time ,width for textNode is determined
  /// so we can know how manay lines this text should have
  private func layoutSecondPass(){
    if manager.layoutNeedsUpdate && !manager.translateRectIntoConstraints{
      let size = contentSizeFor(maxWidth: layoutRect.width)
      if size != .zero{
        manager.updateSize(size, node: self)
      }
    }
    
    subItems.forEach{ $0.layoutSecondPass()}
    manager.layoutNeedsUpdate = false
  }
}

extension Layoutable{
  
  private var depth: Int{
    if let item = superItem{
      return item.depth + 1
    }else{
      return 1
    }
  }
  
  /// find common super item with another LayoutItem
  /// - Parameter item: item to find common superNode with
  /// - Returns: first super node for self and node
  func commonSuperItem(with item: Layoutable?) -> Layoutable?{
    
    guard let item = item else{
      return self
    }
    
    var depth1 = depth
    var depth2 = item.depth
    
    var superItem1: Layoutable = self
    var superItem2 = item
    
    while depth1 > depth2 {
      superItem1 = superItem1.superItem!
      depth1 -= 1
    }
    
    while depth2 > depth1 {
      superItem2 = superItem2.superItem!
      depth2 -= 1
    }
    
    while !(superItem1 === superItem2) {
      if superItem1.superItem == nil{
        return nil
      }
      superItem1 = superItem1.superItem!
      superItem2 = superItem2.superItem!
    }
    
    return superItem1
  }
  
}

extension Layoutable{
  public var left: XAxisAnchor{
    return XAxisAnchor(item: self, attribute: .left)
  }
  
  public var right: XAxisAnchor{
    return XAxisAnchor(item: self, attribute: .right)
  }
  
  public var top: YAxisAnchor{
    return YAxisAnchor(item: self, attribute: .top)
  }
  
  public var bottom: YAxisAnchor{
    return YAxisAnchor(item: self, attribute: .bottom)
  }
  
  public var width: DimensionAnchor{
    return DimensionAnchor(item: self, attribute:.width)
  }
  
  public var height: DimensionAnchor{
    return DimensionAnchor(item: self, attribute:.height)
  }
  
  public var centerX: XAxisAnchor{
    return XAxisAnchor(item: self, attribute: .centerX)
  }
  
  public var centerY: YAxisAnchor{
    return YAxisAnchor(item: self, attribute: .centerY)
  }
  
  public var size: SizeAnchor{
    return SizeAnchor(item: self)
  }
  
  public var center: PositionAnchor{
    return PositionAnchor(item: self, attributes: (.centerX,.centerY))
  }
  
  public var topLeft: PositionAnchor{
    return PositionAnchor(item: self, attributes: (.top,.left))
  }
  
  public var topRight: PositionAnchor{
    return PositionAnchor(item: self, attributes: (.top,.right))
  }
  
  public var bottomLeft: PositionAnchor{
    return PositionAnchor(item: self, attributes: (.bottom,.left))
  }

  public var bottomRight: PositionAnchor{
    return PositionAnchor(item: self, attributes: (.bottom,.right))
  }
  
  /// left and right
  public var xSide: XSideAnchor{
    return XSideAnchor(item: self)
  }
  
  /// top and bottom
  public var ySide: YSideAnchor{
    return YSideAnchor(item: self)
  }
  
  /// top, left, right, bottom
  public var edge: EdgeAnchor{
    return EdgeAnchor(item: self)
  }
  
}


/// LayoutManager hold and handle all the properties needed for layout
/// like SimplexSolver, LayoutProperty ...
/// so that the class conform to LayoutItem does not need to provide those properties
final public class LayoutManager{
  
  weak var solver: SimplexSolver?
  
  var variable = LayoutProperty(scale: Double(UIScreen.main.scale))
  
  // This property is used to adjust position after layout pass
  // It is useful for simplefy layout for irregular layout
  public var offset = CGPoint.zero
  
  /// same as translateAutoSizingMaskIntoConstraints in autolayout
  /// if true, current frame of this item will be add to layout engine
  public var translateRectIntoConstraints = true
  
  public var enabled = true
  
  public var layoutNeedsUpdate = false
  
  var pinedCount = 0
  
  var constraints = [LayoutConstraint]()
  
  private var newAddConstraints = [LayoutConstraint]()
  
  // frequency used Constraint,hold directly to improve performance
  var width: LayoutConstraint?
  var height: LayoutConstraint?
  
  /// used for frame translated constraint
  var minX: LayoutConstraint?
  var minY: LayoutConstraint?
  
  public init(){}
  
  func addConstraintTo(_ solver: SimplexSolver){
    
    // maybe need optiomize
    // find a better way to manager constraint cycle
    // when to add ,when to remove
    self.solver = solver
    variable.solver = solver
    updateConstraint()
  }

  /// add new constraints to current solver
  func updateConstraint(){
    if let solver = self.solver{
      newAddConstraints.forEach {
        $0.addToSolver(solver)
        constraints.append($0)
      }
      newAddConstraints.removeAll()
    }
  }
  
  func addConstraint(_ constraint: LayoutConstraint){
    newAddConstraints.append(constraint)
  }
  
  func removeConstraint(_ constraint: LayoutConstraint){
    if let index = constraints.index(of: constraint){
      constraints.remove(at: index)
      constraint.remove()
    }
  }
  
  /// update content size Constraint
  func updateSize(_ size: CGSize,node: Layoutable, priority: LayoutPriority = .strong){

    if size.width != UIView.noIntrinsicMetric{
      if let width = width{
        width.constant = size.width
      }else{
        width =  node.width == size.width ~ priority
      }
    }

    if size.height != UIView.noIntrinsicMetric{
      if let height = height{
        height.constant = size.height
      }else{
        height = node.height == size.height ~ priority
      }
    }
  }
  
  /// update content size Constraint
  func updateOrigin(_ point: CGPoint,node: Layoutable, priority: LayoutPriority = .required){
    
    if let minX = minX{
      minX.constant = point.x
    }else{
      minX =  node.left == point.x ~ priority
    }
    
    if let minY = minY{
      minY.constant = point.y
    }else{
      minY = node.top == point.y ~ priority
    }
  }
  
  /// final caculated rect for this item
  var layoutRect: CGRect{
    return variable.frame.offsetBy(dx: offset.x,dy: offset.y)
  }
}
