//
//  Constraint.swift
//  Cassowary
//
//  Created by Tang.Nan on 2017/7/24.
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

import Foundation

public enum Relation: CustomDebugStringConvertible{
  case equal
  case lessThanOrEqual
  case greateThanOrEqual
  
  public var debugDescription: String{
    switch self {
    case .equal: return "=="
    case .greateThanOrEqual: return ">="
    case .lessThanOrEqual: return "<="
    }
  }
}

public struct Strength: RawRepresentable,ExpressibleByFloatLiteral{
  
  public typealias RawValue = Double
  
  public typealias FloatLiteralType = Double
  
  public var rawValue: Double
  
  public init(floatLiteral value: Double) {
    self.init(rawValue: value)
  }
  
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
  
  public static let required: Strength = 1000.0
  public static let strong: Strength = 750.0
  public static let medium: Strength = 250.0
  public static let weak: Strength = 10.0
}

final public class Constraint{

  public weak var owner: AnyObject?
  
  public var expr: Expression
  
  public var relation: Relation = .equal
  
  public var strength: Strength
  
  init(expr: Expression = Expression(), strength: Strength = .required) {
    self.expr = expr
    self.strength = strength
  }
  
  init(lhs: Variable, op: Relation, expr: Expression, strength: Strength = .required) {

    switch op {
    case .greateThanOrEqual: expr *= -1 ; expr += lhs
    case .lessThanOrEqual: expr -= lhs
    case .equal: expr -= lhs
    }
    
    self.expr = expr
    self.strength = strength
    self.relation = op
  }
  
  init(lhs: Expression, op: Relation, rhs: Expression, strength: Strength = .required) {
    self.expr = rhs
    self.strength = strength
    self.relation = op
    switch op {
    case .greateThanOrEqual:
      expr *= -1
      expr += lhs
    case .lessThanOrEqual:
      expr -= lhs
    case .equal:
      expr -= lhs
    }
  }
  
  func updateConstant(to constant:Double){
    expr.constant = -constant
  }
  
  var expression: Expression{
    return expr
  }
  
  var isInequality: Bool{
    return relation != .equal
  }
  
  var isRequired: Bool{
    return strength.rawValue >= Strength.required.rawValue
  }

  var weight: Double{
    return strength.rawValue
  }
  
  // temporary use, may be changed lately
  private var hashCache: Int?
}

extension Constraint: CustomDebugStringConvertible{
  public var debugDescription: String{
    return "\(expression.debugDescription) \(relation.debugDescription) 0"
  }
}

extension Constraint: Hashable{
  public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  public var hashValue: Int{
    if let hashCache = hashCache{
      return hashCache
    }
    hashCache = ObjectIdentifier(self).hashValue
    return hashCache!
  }
}

public func == (lhs: Expression, rhs: Expression) -> Constraint{
  return Constraint(expr: lhs - rhs)
}

public func == (lhs: Expression, rhs: Variable) -> Constraint{
  return Constraint(expr: lhs - rhs)
}

public func == (lhs: Variable, rhs: Expression) -> Constraint{
  return rhs == lhs
}

public func == (lhs: Expression, rhs: Double) -> Constraint{
  return Constraint(expr: lhs - rhs)
}

public func == (lhs: Variable, rhs: Variable) -> Constraint{
  return Constraint(expr: Expression(lhs) - rhs)
}

public func == (lhs: Variable, rhs: Double) -> Constraint{
  return Constraint(expr: Expression(lhs, multiply: 1, constant: -rhs))
}


public func <= (lhs: Expression, rhs: Expression) -> Constraint{
  return Constraint(lhs: lhs, op: .lessThanOrEqual, rhs: rhs)
}

public func >= (lhs: Expression, rhs: Expression) -> Constraint{
  return Constraint(lhs: lhs, op: .greateThanOrEqual, rhs: rhs)
}

public func <= (lhs: Expression, rhs: Double) -> Constraint{
  return Constraint(lhs: lhs, op: .lessThanOrEqual, rhs: Expression(constant: rhs))
}

public func >= (lhs: Expression, rhs: Double) -> Constraint{
  return Constraint(lhs: lhs, op: .greateThanOrEqual, rhs: Expression(constant: rhs))
}

public func <= (lhs: Variable, rhs: Expression) -> Constraint{
  return Constraint(lhs: lhs, op: .lessThanOrEqual, expr: rhs)
}

public func >= (lhs: Variable, rhs: Expression) -> Constraint{
  return Constraint(lhs: lhs, op: .greateThanOrEqual, expr: rhs)
}

public func <= (lhs: Variable, rhs: Variable) -> Constraint{
  return Constraint(lhs: lhs, op: .lessThanOrEqual, expr: Expression(rhs))
}

public func >= (lhs: Variable, rhs: Variable) -> Constraint{
  return Constraint(lhs: lhs, op: .greateThanOrEqual, expr: Expression(rhs))
}

public func <= (lhs: Variable, rhs: Double) -> Constraint{
  return Expression(lhs) <= Expression( constant: rhs)
}

public func >= (lhs: Variable, rhs: Double) -> Constraint{
  return Expression(lhs) >= Expression( constant: rhs)
}
