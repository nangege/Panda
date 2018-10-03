//
//  StackLayout.swift
//  Cassowary
//
//  Created by nangezao on 2018/2/10.
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
import Layoutable

public enum StackLayoutAlignment: Int{

  case fill
  
  case leading
  
  case firstBaseline // Valid for horizontal axis only
  
  case center
  
  case trailing
  
  case top
  
  case bottom
  
  case lastBaseline // Valid for horizontal axis only
}

public enum StackLayoutDistribution{
  
  case fill
  
  case fillEqually
  
  case fillProportionally
  
  case equalSpacing
  
  case equalCentering
}


/// Not fully ready yet !!!
open class StackLayoutNode: ViewNode{
  
  required public init(subnodes:[ViewNode] = []) {
    super.init()
    aligmentArrangment.canvas = self
    distributionArrangement.canvas = self
    subnodes.forEach{ addArrangedSubnode($0) }
  }
  
  public var alignment: StackLayoutAlignment = .leading{
    didSet{
      aligmentArrangment.aligment = alignment
      setNeedUpdateConstraint()
    }
  }
  
  public var distribution: StackLayoutDistribution = .fill{
    didSet{
      distributionArrangement.distribution = distribution
      setNeedUpdateConstraint()
    }
  }
  
  public var space: Double = 4{
    didSet{
      distributionArrangement.space = space
      setNeedUpdateConstraint()
    }
  }
  
  public var axis: LayoutAxis = .horizontal{
    didSet{
      aligmentArrangment.axis = axis
      distributionArrangement.axis = axis
      setNeedUpdateConstraint()
    }
  }
  
  private let aligmentArrangment = StackLayoutAlignmentArrangement()
  private let distributionArrangement = StackLayoutDistributionArrangement()
  
  private(set) var arrangedSubnodes = [ViewNode]()
  
  private var needUpdateConstraint = false
  
  public func addArrangedSubnode(_ node: ViewNode){
    arrangedSubnodes.append(node)
    addSubnode(node)
    aligmentArrangment.addItem(node)
    distributionArrangement.addItem(node)
    setNeedUpdateConstraint()
  }
  
  public func addArrangedSubnodes(_ nodes: [ViewNode]){
    nodes.forEach{ addArrangedSubnode($0) }
  }
  
  public func removeArrangedSubnode(_ node: ViewNode){
    if let index = arrangedSubnodes.index(of: node){
      arrangedSubnodes.remove(at: index)
    }
    aligmentArrangment.removeItem(node)
    distributionArrangement.removeItem(node)
    setNeedUpdateConstraint()
  }
  
  private func setNeedUpdateConstraint(){
    needUpdateConstraint = true
  }
  
  override public func updateConstraint() {
    updateConstraintIfNeed()
    super.updateConstraint()
  }
  
  public func updateConstraintIfNeed(){
    if needUpdateConstraint{
      distributionArrangement.updateConstraint()
      aligmentArrangment.updateConstraint()
      needUpdateConstraint = false
    }
  }
  
  func addHiddenObserver(_ node: ViewNode){
    
  }
  
}


class StackLayoutArrangement{
  
  var axis: LayoutAxis = .horizontal
  var items = [ViewNode]()
  var canvasConstraint = [LayoutConstraint]()
  var space: Double = 4
  
  weak var canvas: ViewNode?
  
  var dimensionAttributeForCurrentAxis: LayoutAttribute {
    switch axis {
    case .horizontal: return .height
    case .vertical: return .width
    }
  }
  
  func addItem(_ node: ViewNode){
    items.append(node)
  }
  
  func removeItem(_ node: ViewNode){
    if let index = items.index(of: node){
      items.remove(at: index)
    }
  }
  
  func InvalidIntrinsicContentSizeFor(_ node: ViewNode){
    
  }
  
  func updateConstraint(){
    updateConstraintIfNeed()
  }
  
  func updateConstraintIfNeed(){
    
  }
}

class StackLayoutAlignmentArrangement: StackLayoutArrangement{
  
  var aligment: StackLayoutAlignment = .center
  
  var firstAttribute: LayoutAttribute{
    return dimensionAttributeForCurrentAxis
  }
  
  var secondAttribute: LayoutAttribute{
    switch axis {
    case .horizontal:
      switch aligment {
      case .leading,.top: return .top
      case .center: return .centerY
      case .trailing,.bottom: return .bottom
      default:
        return .bottom
      }
    case .vertical:
      switch aligment {
      case .leading,.top: return .left
      case .center: return .centerX
      case .trailing,.bottom: return .right
      default:
        return .right
      }
    }
  }

  override func updateConstraintIfNeed() {
    canvasConstraint.forEach{ $0.remove() }
    items.forEach { (node) in
      updateFirstAttribute(for: node)
      updateSecondAttribute(for: node)
    }
    
    func updateFirstAttribute(for node: ViewNode){
      let attribute = firstAttribute
      let anchor = Anchor(item: node, attribute: attribute)
      let anchor2 = Anchor(item: canvas!, attribute: attribute)
      var relation: LayoutRelation = .equal
      switch aligment{
      case .fill: relation = .equal
      default: relation = .lessThanOrEqual
      }
      
      let constraint = LayoutConstraint(firstAnchor: anchor,
                                        secondAnchor: anchor2,
                                        relation: relation)
      canvasConstraint.append(constraint)
    }
    
    func updateSecondAttribute(for node: ViewNode){
      let attribute = secondAttribute
      let anchor = Anchor(item: node, attribute: attribute)
      let anchor2 = Anchor(item: canvas!, attribute: attribute)
      var relation: LayoutRelation = .equal
      switch aligment{
      case .fill: relation = .equal
      case .leading: relation = .greatThanOrEqual
      default: relation = .lessThanOrEqual
      }
      
      let constraint = LayoutConstraint(firstAnchor: anchor,
                                        secondAnchor: anchor2,
                                        relation: relation)
      canvasConstraint.append(constraint)
    }
    
  }
}

class StackLayoutDistributionArrangement: StackLayoutArrangement{
  
  typealias ConstraintMapper = NSMapTable<ViewNode, LayoutConstraint>
  
  var distribution: StackLayoutDistribution = .fill
  
  let spaceOrCenterGuide = ConstraintMapper.weakToWeakObjects()
  let edgeToEdgeConstraints = ConstraintMapper.weakToWeakObjects()
  let relatedDimensionConstraints = ConstraintMapper.weakToWeakObjects()
  let hiddingDimensionConstraints = ConstraintMapper.weakToWeakObjects()
  
  var edgeToEdgeRelation: Relation{
    switch distribution {
    case .equalCentering:
      return .greateThanOrEqual
    default:
      return .equal
    }
  }
  
  var minAttributeForGapConstraint: LayoutAttribute{
    switch axis {
    case .horizontal:
      return .left
    case .vertical:
      return .top
    }
  }
  
  func resetFillEffect(){
    
    (items as [Layoutable]).traverse { (preNode, currentNode) -> (LayoutConstraint) in
      var multiply: Double = 1
      if distribution == .fillProportionally{
        let size1 = preNode.itemIntrinsicContentSize
        let size2 = currentNode.itemIntrinsicContentSize
        switch axis{
        case .horizontal:
          multiply = size2.width / size1.width
        case .vertical:
          multiply = size2.height/size1.height
        }
      }
      
      switch axis{
      case .horizontal:
        return currentNode.width == preNode.width * multiply
      case .vertical:
        return currentNode.height == preNode.height * multiply
      }
    }
  }
  
  func resetEquallyEffect(){
    
    if items.count < 1{
      return
    }
    
    let guardView = canvas!
    
    if axis == .horizontal{
      items.first!.left == guardView.left
      items.last!.right == guardView.right
      (items as [Layoutable]).space(space,axis:.horizontal)
    }else{
      items.first!.top == guardView.top
      items.last!.bottom == guardView.bottom
      (items as [Layoutable]).space(space,axis:.vertical)
    }
  }
  
  override func updateConstraintIfNeed() {

    resetEquallyEffect()
    switch distribution {
    case .fillEqually,.fillProportionally: resetFillEffect()
    default: break
    }
  }
}
