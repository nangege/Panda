//
//  AsycDisplayLayer.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2017/12/1.
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

let QueueLabel = "com.nangezao.AsycDisplayQueue"

private let AsyncDisplayQueue = DispatchQueue(label: QueueLabel,
                                              qos: .userInteractive,
                                             target: .global())

typealias CancelBlock = () -> Bool

final class AsyncDisplayLayer: CALayer{
  
  typealias AsyncAction = (Bool) -> ()
  typealias ContentAction = (CancelBlock) -> (UIImage?)
  
  var displaysAsynchronously = true
  
  var willDisplayAction: AsyncAction? = nil
  var displayAction: AsyncAction? = nil
  var didDisplayAction: AsyncAction? = nil
  var contentAction: ContentAction? = nil
  
  private var sentinel = Sentinel()
 
  override init() {
    super.init()
    contentsScale = UIScreen.main.scale
  }
  
  override init(layer: Any) {
    super.init(layer: layer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func display() {
    clear()
    displayAsync(displaysAsynchronously)
  }
  
  func cancel(){
    sentinel.increase()
  }
  
  private func displayAsync(_ async: Bool){
    
    willDisplayAction?(async)
    let value = sentinel.value
    let isCanceled = {
      return self.sentinel.value != value
    }
    
    if async{
      AsyncDisplayQueue.async {
        if let image = self.contentAction?(isCanceled){
          DispatchQueue.main.async {
            if isCanceled(){ return }
            self.contents = image.cgImage
            self.didDisplayAction?(async)
          }
        }
      }
    }else{
      if let image = self.contentAction?(isCanceled){
        self.contents = image.cgImage
        self.didDisplayAction?(async)
      }
    }

  }
  
  func clear(){
    contents = nil
    cancel()
  }
  
  deinit {
    clear()
  }
}

private class Sentinel{
  var value: Int64 = 0
  
  func increase(){
    OSAtomicIncrement64(&value)
  }
}
