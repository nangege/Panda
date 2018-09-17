//
//  FlowLayout.swift
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

// layout subviews，no need to care about layout detail
// if itemWidth and itemWidth is set ,adjust SNFlowLayoutView contentSize
//
// if itemWidth and itemWidth not set ,caculate item size, according to SNFlowLayoutView contentSize，
open class FlowLayoutNode: ViewNode {
  
  /// number of each column
  public var columnCount: Int = 0{
    didSet{
      invalidateIntrinsicContentSize()
    }
  }
  
  /// width for each item. if zero, caculate from columnCount and bounds.size
  public var itemWidth: CGFloat = 0
  
  /// height for each item. if zero, caculate from columnCount and bounds.size.height
  public var itemHeight: CGFloat = 0
  
  /// space between item
  public var itemSpace: CGFloat = 0
  
  /// lineSpace
  public var lineSpace: CGFloat = 0
  
  /// if item is square，if true and itemWidth not set ，set itemHeight = itemHeight
  /// if aspectRatio > 0 and itemHeight is zero, itemHeight = itemWidth *aspectRatio
  public var aspectRatio: CGFloat = -1
  
  /// contentInset
  public var inset: UIEdgeInsets = .zero
  
  /// if true ,layout in the form   |space|view|space|view|space|
  /// if false layout in the form   |view|space|view|
  public var withMargin = false
  
  
  private var rowCount: Int{
    get{ return Int((validNode.count - 1)/columnCount) + 1}
  }
  
  private var validNode:[ViewNode]{
    return subnodes.filter{ $0.hidden == false }
  }
  
  convenience init(nodes: [ViewNode]){
    self.init()
    addArrangedNodes(nodes)
  }
  
  public func addArrangedNodes(_ nodes: [ViewNode]){
    nodes.forEach { addSubnode($0)}
  }
  
  open override func removeSubnode(_ node: ViewNode) {
    super.removeSubnode(node)
    invalidateIntrinsicContentSize()
  }
  
  open override func addSubnode(_ node: ViewNode) {
    super.addSubnode(node)
    invalidateIntrinsicContentSize()
  }
  
  override public func layoutSubnode() {
    guard validNode.count > 0 ,columnCount > 0 else { return }

    let size = itemSize(for: bounds.size)
    let width = size.width
    let height = size.height

    var cellSpace = itemSpace
    let totalSpace = bounds.width - inset.xAxis - columnCount * width
    if cellSpace < 0.01 {
        cellSpace = totalSpace/(columnCount + (withMargin ? 1 : -1))
    }
    for (index, item) in validNode.enumerated(){
      let xIndex = index % columnCount
      let yIndex = index/columnCount

      let x = inset.left + xIndex*(width + cellSpace) + (withMargin ? cellSpace : 0 )
      let y = inset.top + yIndex*(height + lineSpace)
      item.frame = CGRect(x: x, y: y, width: width, height: height)
    }
    
  }
  
  private func itemSize(for size: CGSize) -> CGSize {
    
    var width = itemWidth
    
    if width < 0.01 {
      let space = (columnCount - (withMargin ? -1 : 1))*itemSpace
      width = (size.width - inset.xAxis - (columnCount - 1) * space)/columnCount
    }
    
    var height = itemHeight
    
    if height < 0.01 {
      if aspectRatio > 0 {
        height = width * aspectRatio
      }
      else{
        height = (size.height - inset.yAxis - (rowCount - 1)*lineSpace)/rowCount
      }
    }
    return CGSize(width: width, height: height)
  }
  
  public override  var intrinsicContentSize: CGSize{
    guard validNode.count > 0,columnCount > 0 else { return .zero }
    let size = itemSize(for: bounds.size)
    
    return contenSizeForItemSize(size)
  }
  
  public override func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    guard validNode.count > 0,columnCount > 0 else { return .zero }
    let size = itemSize(for: CGSize(width: maxWidth, height: bounds.height))
    
    return contenSizeForItemSize(size)
  }
  
  private func contenSizeForItemSize(_ size: CGSize) -> CGSize{
    let spaceX = (columnCount - 1)*itemSpace
    let spaceY = (rowCount - 1)*lineSpace
    
    let width = inset.xAxis + columnCount*size.width + spaceX
    let height = inset.yAxis + rowCount*size.height + spaceY
    
    return CGSize(width: width, height: height)
  }
  
}

private func * (lhs: Int, rhs: CGFloat) -> CGFloat{
  return CGFloat(lhs) * rhs
}

private func / (lhs: CGFloat, rhs: Int) -> CGFloat{
  return lhs / CGFloat(rhs)
}

extension UIEdgeInsets{
  fileprivate var xAxis: CGFloat{
    return left + right
  }
  
  fileprivate var yAxis: CGFloat{
    return top + bottom
  }
}
