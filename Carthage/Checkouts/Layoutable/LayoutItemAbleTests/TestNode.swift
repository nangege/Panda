//
//  TestNode.swift
//  LayoutableTests
//
//  Created by nangezao on 2018/9/4.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import Foundation
@testable import Layoutable

class TestNode: Layoutable{
  
  public init() {}
  
  var manager: LayoutManager = LayoutManager()
  
  var size = CGSize.zero
  
  var intrinsicContentSize: CGSize {
    return size
  }
  
  weak var superItem: Layoutable? = nil
  
  var subItems = [Layoutable]()
  
  var frame: CGRect = .zero
  
  func addSubnode(_ node: TestNode){
    subItems.append(node)
    node.superItem = self
  }
  
  func layoutSubnode() {}
  
  func updateConstraint() {}
  
  func contentSizeFor(maxWidth: CGFloat) -> CGSize {
    return .zero
  }
  
  
}
