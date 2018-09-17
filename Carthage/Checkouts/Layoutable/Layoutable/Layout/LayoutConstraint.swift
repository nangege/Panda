//
//  LayoutConstraint.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/3/20.
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

public enum LayoutRelation {
  case equal
  case lessThanOrEqual
  case greatThanOrEqual
}

extension LayoutRelation: CustomDebugStringConvertible{
  public var debugDescription: String {
    switch self {
    case .equal: return "=="
    case .lessThanOrEqual: return "<="
    case .greatThanOrEqual: return ">="
    }
  }
}

public struct LayoutPriority: RawRepresentable,ExpressibleByFloatLiteral{
  public init(rawValue: Double) {
    self.rawValue = rawValue
  }
  
  public var rawValue: Double
  
  public init(floatLiteral value: Double) {
    rawValue = value
  }
  
  public typealias RawValue = Double
  
  public typealias FloatLiteralType = Double
  
  public static let required: LayoutPriority = 1000.0
  public static let strong: LayoutPriority = 750.0
  public static let medium: LayoutPriority = 250.0
  public static let weak: LayoutPriority = 10.0
}

public enum LayoutAttribute{
  
  case left
  
  case right
  
  case top
  
  case bottom
  
  case width
  
  case height
  
  case centerX
  
  case centerY
}

extension LayoutAttribute: CustomDebugStringConvertible{
  public var debugDescription: String {
    switch self {
    case .left: return "left"
    case .right: return "right"
    case .top: return "top"
    case .bottom: return "bottom"
    case .width: return "width"
    case .height: return "height"
    case .centerX: return "centerX"
    case .centerY: return "centerY"
    }
  }
}

open class LayoutConstraint{
  
  public init(firstAnchor: AnchorType,secondAnchor: AnchorType? = nil, relation: LayoutRelation = .equal, multiplier: CGFloat = 1,constant: CGFloat = 0){
    self.firstAnchor = firstAnchor
    self.secondAnchor = secondAnchor
    self.relation = relation
    self.constant = constant
    self.multiplier = multiplier
    
    // maybe this code should not be here, need to be fix
    firstAnchor.item.manager.translateRectIntoConstraints = false
    firstAnchor.item.addConstraint(self)
    secondAnchor?.item.manager.pinedCount += 1
  }
  
  public let firstAnchor: AnchorType
  
  public let secondAnchor: AnchorType?
  
  public let relation: LayoutRelation
  
  public let multiplier: CGFloat
  
  open var constant: CGFloat = 0{
    didSet{
      if let solver = solver , constant != oldValue{
        solver.updateConstant(for: constraint, to: Double(constant))
      }
    }
  }
  
  open var priority: LayoutPriority = .required{
    didSet{
      if let solver = solver{
        try? solver.updateStrength(for: constraint, to: Strength(rawValue: priority.rawValue))
      }
    }
  }
  
  open var isActive: Bool = false
  
  fileprivate weak var solver: SimplexSolver? = nil
  
  // translate LayoutConstraint to Constraint
  lazy var constraint: Constraint = {
    
    var constraint: Constraint!
    let superItem = firstAnchor.item.commonSuperItem(with: secondAnchor?.item)
    
    var lhsExpr = firstAnchor.expression(in: superItem)
    let rhsExpr = Expression(constant: Double(constant))
    
    if let secondAnchor = secondAnchor{
      rhsExpr += secondAnchor.expression(in: superItem)*Double(multiplier)
    }else{
      lhsExpr = firstAnchor.expression()
    }
  
    switch relation {
    case .equal:
      constraint = lhsExpr == rhsExpr
    case .greatThanOrEqual:
      constraint =  lhsExpr >= rhsExpr
    case .lessThanOrEqual:
      constraint = lhsExpr <= rhsExpr
    }
  
    constraint.strength = Strength(rawValue: priority.rawValue)
    constraint.owner = self
    return constraint
  }()
  
}

extension LayoutConstraint{
  
  func addToSolver(_ solver: SimplexSolver){
    self.solver = solver
    do{
      try solver.add(constraint: constraint)
    }catch ConstraintError.requiredFailureWithExplanation(let constraint){
      let tips = """
                 Unable to simultaneously satisfy constraints.
                 Probably at least one of the constraints in the following list is one you don't want.
                 Try this:
                 (1) look at each constraint and try to figure out which you don't expect;
                 (2) find the code that added the unwanted constraint or constraints and fix it.
                 """
      print(tips)
      constraint.forEach{ print("   \(String(describing: $0.owner)) " ) }
      
      print("""
            Will attempt to recover by breaking constraint
                \(self)
            """)
    }catch{
      print(error)
    }
  }
  
  public func remove(){
    _ = try? solver?.remove(constraint: constraint)
    secondAnchor?.item.manager.pinedCount -= 1
    solver = nil
  }

  func active(_ active: Bool = true){
    self.isActive = true
  }
  
  @discardableResult func priority(_ priority: LayoutPriority) -> LayoutConstraint{
    self.priority = priority
    return self
  }
}

extension LayoutConstraint: Hashable{
  public var hashValue: Int {
    return  ObjectIdentifier(self).hashValue
  }
  
  public static func ==(lhs: LayoutConstraint, rhs: LayoutConstraint) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
}

infix operator ~:TernaryPrecedence

// syntax surge for setPriority
// item1.left = item2.right + 10 ~ .strong
@discardableResult public func ~(lhs: LayoutConstraint, rhs: LayoutPriority) -> LayoutConstraint{
  lhs.priority = rhs
  return lhs
}

extension LayoutConstraint: CustomStringConvertible{
  public var description: String {
    let lhsdesc = "\(firstAnchor.item!).\(firstAnchor.attribute)"
    var desc = lhsdesc
    if let rhsAnchor = self.secondAnchor{
      let rhsdesc = "\(rhsAnchor.item!).\(rhsAnchor.attribute)"
      desc = "\(lhsdesc) \(relation) \(rhsdesc)*\(multiplier) + \(constant)"
    }else{
      desc = "\(lhsdesc) \(relation) \(constant)"
    }
    return desc
  }
}
