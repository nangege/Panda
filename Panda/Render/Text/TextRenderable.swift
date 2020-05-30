//
//  TextRenderable.swift
//  Panda
//
//  Created by nangezao on 2018/10/3.
//  Copyright © 2018 Tang Nan. All rights reserved.
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

import Foundation

public protocol TextRenderable: class {
  var textHolder: TextAttributesHolder{ get }
  func attributeUpdate(affectSize : Bool)
}

public class TextAttributesHolder{
  
  weak var render: TextRenderable?
  
  init(_ render: TextRenderable) {
    self.render = render
  }
  
  public var text: String = ""{
    didSet{
      useAttributedText = false
      if text != oldValue{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var attributeText: NSAttributedString?{
    didSet{
      useAttributedText = true
      if attributeText != oldValue{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var textColor = UIColor.black{
    didSet{
      if oldValue != textColor{
        render?.attributeUpdate(affectSize: false)
      }
    }
  }
  
  public var font = UIFont.systemFont(ofSize: 17){
    didSet{
      if oldValue != font{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var numberOfLines = 1{
    didSet{
      if oldValue != numberOfLines{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var lineSpace: CGFloat?{
    didSet{
      if oldValue != lineSpace{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var truncationMode: NSLineBreakMode = .byTruncatingTail{
    didSet{
      if oldValue != truncationMode{
        render?.attributeUpdate(affectSize: true)
      }
    }
  }
  
  public var useAttributedText = false
  
  public var itemIntrinsicContentSize: CGSize{
    
    if textAttributes.attributeString.length == 0{
      return .zero
    }
    
    let maxWidth = CGFloat.infinity
    let size = CGSize(width: maxWidth, height: .infinity)
    
    return render(for: CGRect(origin: .zero, size: size)).size
  }
  
  func sizeFor(maxWidth: CGFloat) -> CGSize {
    if textAttributes.attributeString.length == 0{
      return .zero
    }
    
    let size = CGSize(width: maxWidth, height: .infinity)
    
    return render(for: CGRect(origin: .zero, size: size)).size
  }
  
  func render(for bounds: CGRect) -> TextRender{
    return TextRender.render(for: textAttributes, constrainedSize: bounds.size)
  }
  
  public var textAttributes: TextAttributes{
    
    var usedAttributeText: NSAttributedString
    
    if let attributeText = attributeText,useAttributedText{
      usedAttributeText = attributeText
    }else{
      let attributes:[NSAttributedString.Key: Any] = [.font:font,
                                                      .foregroundColor: textColor]
      usedAttributeText = NSAttributedString(string: text as String,attributes: attributes)
    }
    
    if let lineSpace = lineSpace{
      let style = NSMutableParagraphStyle()
      style.lineSpacing = lineSpace
      let attributedText = NSMutableAttributedString(attributedString: usedAttributeText)
      attributedText.addAttributes([.paragraphStyle: style], range: attributedText.range)
      usedAttributeText = attributedText
    }
    
    var attributes = TextAttributes()
    attributes.attributeString = usedAttributeText
    attributes.maximumNumberOfLines = numberOfLines
    attributes.lineBreakMode = truncationMode
    
    return attributes
  }
  
}

extension NSAttributedString{
  var range: NSRange{
    return NSRange(location: 0, length: length)
  }
}
