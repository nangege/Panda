//
//  Expression.swift
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

final public class Expression{
  
  public typealias ValueType = Double
  public typealias Term = TermsMapper.Element
  public typealias TermsMapper = [Variable: ValueType]

  var constant: ValueType = 0
  
  private(set) var terms = TermsMapper()
  
  var isConstant: Bool{
    return terms.isEmpty
  }

  public init(_ variable: Variable? = nil, multiply: ValueType = 1, constant: ValueType = 0) {
    self.constant = constant
    if let variable = variable {
      terms[variable] = multiply
    }
  }

  public init(expr: Expression) {
    constant = expr.constant
    terms = expr.terms
  }
}

extension Expression{
  
  var pivotableVar: Variable?{
    assert(!isConstant)
    for variable in terms.keys{
      if variable.isPivotable{
        return variable
      }
    }
    return nil
  }
  
  @discardableResult func solve(for variable: Variable) -> Double{
    assert(terms.keys.contains(variable))
    let value = terms.removeValue(forKey: variable)!
    let reciprocal = 1/value
    self *= -reciprocal
    return reciprocal
  }
  
  func changeSubject(from old: Variable, to: Variable){
    if old == to {
      return
    }
    terms[old] = solve(for: to)
  }

  public func earse(_ variable: Variable){
    terms.removeValue(forKey: variable)
  }
  
  public func coefficient(for variable: Variable) -> ValueType{
    return terms[variable] ?? 0
  }
  
  // increase constant of e = c to e = c + value
  // present as e + (-c - value) = 0
  func increaseConstant(by value: ValueType){
    constant += -value
  }
  
  func substituteOut(_ variable: Variable, with expr: Expression) {
    guard let  coefficient = terms.removeValue(forKey: variable) else{
      return
    }
    add(expr: expr, multiply: coefficient)
  }
  
  func add(expr: Expression,multiply: Double = 1){
    constant += expr.constant * multiply
    expr.terms.forEach {
      add($0.key, multiply: $0.value * multiply)
    }
  }
}

extension Expression{
  public static func += (lhs: Expression, rhs: Variable){
    lhs.add(rhs)
  }
  
  public static func -= (lhs: Expression, rhs: Variable){
    lhs.add(rhs, multiply: -1)
  }
  
  public static func += (lhs: Expression, rhs: Double){
    lhs.constant += rhs
  }
  
  public static func -= (lhs: Expression, rhs: Double){
    lhs += -rhs
  }
  
  public static func += (lhs: Expression, rhs: Expression){
    lhs.add(expr: rhs)
  }
  
  public static func -= (lhs: Expression, rhs: Expression){
    lhs.minus(rhs)
  }
  
  public static func *= (lhs: Expression, rhs: Double){
    lhs.multiply(by: rhs)
  }
  
  public static func /= (lhs: Expression, rhs: Double){
    lhs.divide(by: rhs)
  }
  
  public static func * (lhs: Expression, rhs: Double) -> Expression{
    let expr = Expression()
    for (v, c) in lhs.terms{
      expr.add(v, multiply: c*rhs)
    }
    expr.constant = lhs.constant * rhs
    return expr
  }

  public static func / (lhs: Expression, rhs: Double) -> Expression{
    return lhs * (1/rhs)
  }
  
  public static func * (lhs: Double, rhs: Expression) -> Expression{
    return rhs * lhs
  }
}

extension Expression{
  private func multiply(by mul: ValueType){
    constant *= mul
    for (key, value) in terms{
      terms[key] = value*mul
    }
  }
  
  private func divide(by div: ValueType){
    assert(div == 0, "divide value can not be zero")
    multiply(by: 1/div)
  }
  
  func add(_ variable: Variable, multiply: Double = 1){
    if let value = terms[variable]{
      if !nearZero(value + multiply){
        terms[variable] = value + multiply
      }else{
        terms.removeValue(forKey: variable)
      }
    }else{
      if !nearZero(multiply){
        terms[variable] = multiply
      }
    }
  }
  
  private func minus(_ exp: Expression){
    constant -= exp.constant
    exp.terms.forEach {
      add($0.key, multiply: -$0.value)
    }
  }
}

extension Expression: CustomDebugStringConvertible{
  public var debugDescription: String{
    var expr = ""
    for (v, c) in terms{
      expr += "\(v)*\(c) + "
    }
    expr += "\(constant)"
    return expr
  }
}

/* surg for Expression Operation
   write expression like e + c ,e*c
 */

public func * (v: Variable, x: Double) -> Expression{
  return Expression(v, multiply: x)
}

public func * (x: Double,v: Variable) -> Expression{
  return v*x
}

public func / (v: Variable, x: Double) -> Expression{
  return  v * 1.0 / x
}

public func + (v: Variable, x: Double) -> Expression{
  return Expression(v, constant: x)
}

public func + (v: Expression, x: Double) -> Expression{
  let expr = Expression(expr: v)
  expr.constant += x
  return expr
}

public func - (v: Expression, x: Double) -> Expression{
  return v + (-x)
}

public func - (v: Variable, x: Double) -> Expression{
  return Expression(v, multiply: 1, constant: -x)
}

public func - (x: Double, v: Variable) -> Expression{
  return Expression(v, multiply: -1, constant: x)
}

public func - (expr: Expression, v: Variable) -> Expression{
  let result = Expression(expr: expr)
  result -= v
  return result
}

public func + (expr: Expression, v: Variable) -> Expression{
  let result = Expression(expr: expr)
  result += v
  return result
}

public func + (lhs: Expression, rhs: Expression) -> Expression{
  let result = Expression(expr: lhs)
  result += rhs
  return result
}

public func - (lhs: Expression, rhs: Expression) -> Expression{
  let result = Expression(expr: lhs)
  result -= rhs
  return result
}

public func + (lhs: Variable, rhs: Variable) -> Expression{
  let expr = Expression(lhs)
  expr += rhs
  return expr
}

public func - (lhs: Variable, rhs: Variable) -> Expression{
  let expr = Expression(lhs)
  expr -= rhs
  return expr
}
