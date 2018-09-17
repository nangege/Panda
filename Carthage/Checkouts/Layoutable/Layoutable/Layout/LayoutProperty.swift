//
//  Layout.swift
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

class LayoutProperty{
  
  init(scale: Double) {
    self.scale = scale
  }
  
  let x = Variable()
  let y = Variable()
  let width = Variable()
  let height = Variable()
  
  weak var solver: SimplexSolver?
  
  var scale: Double = 1

  var frame: CGRect{
    guard let solver = solver else{
      return .zero
    }
    let minX = solver.valueFor(x).pixelRound(to: scale)
    let minY = solver.valueFor(y).pixelRound(to: scale)
    let w = solver.valueFor(width).pixelRound(to: scale)
    let h = solver.valueFor(height).pixelRound(to: scale)
    return CGRect(x: minX, y: minY, width: w, height: h)
  }
  
  func expressionFor(attribue: LayoutAttribute) -> Expression{
    switch attribue {
    case .left:
      return Expression(x)
    case .top:
      return Expression(y)
    case .right:
      return x + width
    case .bottom:
      return  y + height
    case .width:
      return  Expression(width)
    case .height:
      return Expression(height)
    case .centerX:
      return width/2 + x
    case .centerY:
      return height/2 + y
    }
  }
}

