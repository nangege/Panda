//
//  ProxyView.swift
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


/// ProxyView for ViewNode, forward gesture event to ViewNode
class ProxyView: UIView{

  weak var node: ViewNode?
  
  private var inHitTest = false
  
  private var inPointInside = false
  
  open override class var layerClass: Swift.AnyClass {
    return AsyncDisplayLayer.self
  }
  
  init(for node: ViewNode, layerAction: (AsyncDisplayLayer) -> ()) {
    super.init(frame: CGRect.zero)
    self.node = node
    layerAction(layer as! AsyncDisplayLayer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let node = node else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    return node.gestureRecognizerShouldBegin(gestureRecognizer)
  }
  
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    if !inHitTest{
      inHitTest = true
      let hitTestView = node?.hitTest(point, with: event)
      inHitTest = false
      return hitTestView
    }else{
      return super.hitTest(point, with: event)
    }
  }
  
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard let node = node else{
      return false
    }
    if !inPointInside{
      inPointInside = true
      let pointInside = node.point(inside:point, with:event)
      inPointInside = false
      return pointInside
    }else{
      return super.point(inside: point, with: event)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    node?.touchesBegan(touches, with: event)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    node?.touchesMoved(touches, with: event)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    node?.touchesCancelled(touches, with: event)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    node?.touchesEnded(touches, with: event)
  }

  open func forwardGestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
    return super.gestureRecognizerShouldBegin(gestureRecognizer)
  }
  
  open func forwardTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    super.touchesBegan(touches, with: event)
  }
  
  open func forwardTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
    super.touchesMoved(touches, with: event)
  }
  
  open func forwardTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
    super.touchesEnded(touches, with: event)
  }
  
  open func forwardTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
    super.touchesCancelled(touches, with: event)
  }
  
}
