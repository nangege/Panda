//
//  ViewNode.swift
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
import Layoutable

open class ViewNode: Layoutable {
  
  open private(set) weak var superNode: ViewNode?
  
  open private(set) var subnodes = [ViewNode]()
  
  open var userInteractionEnabled = true
  
  open var backgroundColor: UIColor = .clear{
    didSet{
      if oldValue != backgroundColor{
        commitUpdate()
      }
    }
  }
  
  open var alpha: CGFloat = 1{
    didSet{
      if oldValue != alpha {
        commitUpdate()
      }
    }
  }
  
  open var borderColor = UIColor.clear{
    didSet{
      if oldValue != borderColor{
        commitUpdate()
      }
    }
  }
  
  open var borderWidth: CGFloat = 0{
    didSet{
      if oldValue != borderWidth{
        commitUpdate()
      }
    }
  }
  
  open var cornerRadius: CGFloat = 0{
    didSet{
      if oldValue != cornerRadius{
        commitUpdate()
      }
    }
  }
  
  open var frame: CGRect = .zero{
    didSet{
      if oldValue != frame{
        frameDidUpdate = true
        setNeedsDisplay()
        layoutSubnode()
      }
    }
  }
  
  open var hidden = false{
    didSet{
      if oldValue != hidden{
        commitUpdate()
      }
    }
  }
  
  open var bounds: CGRect{
    return CGRect(origin: .zero, size: frame.size)
  }
  
  // make sure to call this on main thread
  private lazy var displayView = ProxyView(for: self){ (layer: AsyncDisplayLayer) in
    layer.contentAction = { [weak self] ( isCanceled: CancelBlock) in
      self?.contentForLayer(layer, isCancel: isCanceled)
    }
  }
  
  public var layer: CALayer{
    return view.layer
  }
  
  public var view: UIView{
    assert(Thread.current.isMainThread, "view property should be called from main thread")
    displayView.isUserInteractionEnabled = userInteractionEnabled
    
    // need to optimize
    if isInHierarchy{
      subnodes.forEach{
        if !$0.isInHierarchy{
          displayView.addSubview($0.view)
        }
      }
      return displayView
    }
    isInHierarchy = true
    
    subnodes.forEach{ displayView.addSubview($0.view)}
    return displayView
  }
  
  private var isInHierarchy = false
  
  var viewNeedsUpdate = false
  var layerNeedsDisplay = false
  var frameDidUpdate = false
  
  // change access control level to public
  public init(){}
  
  open func sizeToFit(){
    frame = CGRect(origin: frame.origin, size: intrinsicContentSize)
  }
  
  open func sizeThatFit(_ size: CGSize) -> CGSize{
    return intrinsicContentSize.constrainted(to: size)
  }
  
  open func setNeedsDisplay(){
    layerNeedsDisplay = true
    Transaction.addObserver(self)
  }
  
  open func setNeedsLayout(){
    manager.layoutNeedsUpdate = true
    Transaction.addObserver(self)
  }
  
  open func invalidateIntrinsicContentSize(){
    setNeedsLayout()
  }
  
  func commitUpdate(){
    viewNeedsUpdate = true
    Transaction.addObserver(self)
  }
  
  func updateIfNeed(){
    
    if viewNeedsUpdate{
      view.isHidden = hidden
      view.alpha = alpha
      view.backgroundColor = backgroundColor
      view.layer.borderColor = borderColor.cgColor
      view.layer.borderWidth = borderWidth
      view.layer.cornerRadius = cornerRadius
      viewNeedsUpdate = false
    }

    if frameDidUpdate{
      view.frame = frame
      frameDidUpdate = false
    }
    
    if layerNeedsDisplay{
      layer.setNeedsDisplay()
      layerNeedsDisplay = false
    }
  }
  
  public func layoutIfNeeded(){
    layoutIfEnabled()
  }
  
  public var intrinsicContentSize: CGSize{
    return CGSize(width: UIView.noIntrinsicMetric,
                  height: UIView.noIntrinsicMetric)
  }
  
  // Overrde this method to provide custom drawing Content
  // This method may running in background thread
  open func drawContent(in context: CGContext){}

  open func addSubnode(_ node: ViewNode){
    node.superNode = self
    subnodes.append(node)
  }
  
  open func addSubnodes(_ nodes: [ViewNode]){
    nodes.forEach{ addSubnode($0)}
  }
  
  open func removeSubnode(_ node: ViewNode){
    if let index = subnodes.index(of: node){
      node.superNode = nil
      subnodes.remove(at: index)
      if node.isInHierarchy{
        node.view.removeFromSuperview()
      }
    }
  }
  
  open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
    return (view as! ProxyView).forwardGestureRecognizerShouldBegin(gestureRecognizer)
  }
  
  open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    (view as! ProxyView).forwardTouchesBegan(touches, with: event)
  }
  
  open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
    (view as! ProxyView).forwardTouchesMoved(touches, with: event)
  }
  
  open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
    (view as! ProxyView).forwardTouchesEnded(touches, with: event)
  }
  
  open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
    (view as! ProxyView).forwardTouchesCancelled(touches, with: event)
  }
  
  open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?{
    return view.hitTest(point, with:event)
  }
  
  open func point(inside point: CGPoint, with event: UIEvent?) -> Bool{
    return view.point(inside:point, with:event)
  }
  
  open func convert(_ point: CGPoint, to node: ViewNode?) -> CGPoint{
    return view.convert(point, to: node?.view)
  }
  
  open func convert(_ point: CGPoint, from node: ViewNode?) -> CGPoint{
    return view.convert(point, from: node?.view)
  }
  
  open func convert(_ rect: CGRect, to node: ViewNode?) -> CGRect{
    return view.convert(rect, to: node?.view)
  }
  
  open func convert(_ rect: CGRect, from node: ViewNode?) -> CGRect{
    return view.convert(rect, from: node?.view)
  }
  
  // Layoutable protocol
  public var superItem: Layoutable?{
    return superNode
  }
  
  public var subItems: [Layoutable]{
    return subnodes
  }
  
  public var manager =  LayoutManager()

  public func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    return .zero
  }
  
  public func updateConstraint() {}
  
  public func layoutSubnode() {}
  
// delegate for AsyncDisplayLayer
// provide contents for CALayer asynchronously
  func contentForLayer(_ layer: AsyncDisplayLayer, isCancel: () -> Bool) -> UIImage? {
    if isCancel(){ return nil }
    
    let size = layer.bounds.size
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    defer { UIGraphicsEndImageContext() }
    
    guard let context = UIGraphicsGetCurrentContext() else{
      return nil
    }
    
    if isCancel(){ return nil }
    
    drawContent(in: context)
    
    if isCancel(){ return nil }
    
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}

extension ViewNode: Hashable{

  public static func ==(lhs: ViewNode, rhs: ViewNode) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  public var hashValue: Int{
    return ObjectIdentifier(self).hashValue
  }
}

extension ViewNode: RunloopObserver{
  func runLoopDidUpdate() {
    /// if node is not inHierarchy,auto update is meaningless
    /// and will cause some problem
    if !isInHierarchy{
      return
    }
    
    if manager.layoutNeedsUpdate{
      layoutIfNeeded()
    }
    updateIfNeed()
  }
}

