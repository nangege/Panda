//
//  TextNode.swift
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

public class TextNode: ControlNode {
  
  public var text: String = ""{
    didSet{
      useAttributeText = false
      if text != oldValue{
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
      }
    }
  }
  
  public var attributeText: NSAttributedString?{
    didSet{
      useAttributeText = true
      if attributeText != oldValue{
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
      }
    }
  }
  
  public var textColor = UIColor.black{
    didSet{
      if oldValue != textColor{
        setNeedsDisplay()
      }
    }
  }
  
  public var font = UIFont.systemFont(ofSize: 17){
    didSet{
      if oldValue != font{
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
      }
    }
  }
  
  public var numberOfLines = 1{
    didSet{
      if oldValue != numberOfLines{
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
      }
    }
  }
  
  public var truncationMode: NSLineBreakMode = .byWordWrapping
  
  private var useAttributeText = false
  
  override public var intrinsicContentSize: CGSize{
    
    if textAttributes.attributeString.length == 0{
      return .zero
    }
    
    let maxWidth = CGFloat.infinity
    let size = CGSize(width: maxWidth, height: .infinity)
    
    let textRender = render(for: CGRect(origin: .zero, size: size))
    return textRender.size
  }
  
  public override func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    // need optimize
    let textSize = intrinsicContentSize
    if textSize.width <= maxWidth || numberOfLines == 1{
      return .zero
    }
    
    let size = CGSize(width: maxWidth, height: .infinity)
    
    return render(for: CGRect(origin: .zero, size: size)).size
  }
  
  override public func drawContent(in context: CGContext) {
  
    let textRender = render(for: bounds)
    
    textRender.drawInContext(context, bounds: bounds)
  }
  
  private func render(for bounds: CGRect) -> TextRender{
    return TextRender.render(for: textAttributes, constrainedSize: bounds.size)
  }
  
  private var textAttributes: TextAttributes{
    
    var usedAttributeText: NSAttributedString
    
    if let attributeText = attributeText,useAttributeText{
      usedAttributeText = attributeText
    }else{
      let attributes:[NSAttributedString.Key: Any] = [.font:font,
                                                      .foregroundColor: textColor]
      usedAttributeText = NSAttributedString(string: text as String,attributes: attributes)
    }
    
    var attributes = TextAttributes()
    attributes.attributeString = usedAttributeText
    attributes.maximumNumberOfLines = numberOfLines
    attributes.lineBreakMode = truncationMode

    return attributes
  }
}
