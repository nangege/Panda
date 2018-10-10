//
//  TextKitRender.swift
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
import CoreGraphics

final public class TextRender{
  
  /// we do not use NSCache here. NSCache‘s auto-removal policies is unpredictable
  /// which may degrade performance significantly sometimes
  /// textRender cache only cost small memory,we don't need to clean up even when we have memory issuse
  /// if no long in use ,clean cache manully
  private typealias RenderCache = NSMapTable<TextKitRenderKey, TextRender>

  private static let cache = RenderCache.strongToStrongObjects()
  
  private static var cachePool = [RenderCache]()
  
  public let textAttributes: TextAttributes
  public let textContext: TextContext
  public let constraintSize: CGSize
  
  private(set) var size: CGSize = .zero
  
  init(textAttributes: TextAttributes,constraintSize: CGSize) {
    
    self.textAttributes = textAttributes
    self.constraintSize = constraintSize
    
    textContext = TextContext(attributeText:textAttributes.attributeString,
                                 lineBreakMode: textAttributes.lineBreakMode,
                                 maxNumberOfLines: textAttributes.maximumNumberOfLines,
                                 exclusionPaths: textAttributes.exclusionPaths,
                                 constraintSize: constraintSize)
    updateTextSize()
    
  }
  
  public class func render(for attributes: TextAttributes,
                           constrainedSize: CGSize) -> TextRender{
    
    let key = TextKitRenderKey(attributes: attributes, constrainedSize: constrainedSize)

    if let render = currentCache.object(forKey: key){
      return render
    }
    
    let render =  TextRender(textAttributes: attributes, constraintSize: constrainedSize)
    
    currentCache.setObject(render, forKey: key)
    
    return render
  }
  
  public class func cleanCache(){
    cache.removeAllObjects()
  }
  
  public class func cleanCachePool(){
    cachePool.removeAll()
  }
  
  public class func pushCache(){
    cachePool.append(RenderCache.strongToStrongObjects())
  }
  
  public class func popCache(){
    _ = cachePool.popLast()
  }
  
  private static var currentCache: RenderCache{
    return cachePool.last ?? cache
  }
  
  private func updateTextSize(){
    textContext.performBlockWithLockedComponent { (layoutManager, textContainer, textStorage) in
      layoutManager.ensureLayout(for: textContainer)
      size = layoutManager.usedRect(for: textContainer).size
    }
  }
  
  public func drawInContext(_ context: CGContext, bounds: CGRect){
    context.saveGState()
    UIGraphicsPushContext(context)
    
    textContext.performBlockWithLockedComponent { (layoutManager, textContainer, storage) in
      let range = layoutManager.glyphRange(forBoundingRect: bounds, in: textContainer)
      layoutManager.drawBackground(forGlyphRange: range, at: .zero)
      layoutManager.drawGlyphs(forGlyphRange: range, at: .zero)
    }
    
    UIGraphicsPopContext()
    context.restoreGState()
  }
    
}

private class TextKitRenderKey: NSObject{

  let attributes: TextAttributes
  let constrainedSize: CGSize
  var hasherResult = 0
  
  init(attributes: TextAttributes, constrainedSize: CGSize) {
    self.attributes = attributes
    self.constrainedSize = constrainedSize
    
    var hasher = Hasher()
    hasher.combine(attributes)
    hasher.combine(constrainedSize)
    hasherResult = hasher.finalize()
  }
  
  static func ==(lhs: TextKitRenderKey, rhs: TextKitRenderKey) -> Bool {
    return lhs.constrainedSize == rhs.constrainedSize &&
           lhs.attributes == rhs.attributes
  }
  
  override var hash: Int{
    return hasherResult
  }
  
  override func isEqual(_ object: Any?) -> Bool {
    guard let value = object as? TextKitRenderKey else{
      return false
    }
    return self == value
  }
}

extension CGSize: Hashable{
  public func hash(into hasher: inout Hasher) {
    hasher.combine(width)
    hasher.combine(height)
  }
}
