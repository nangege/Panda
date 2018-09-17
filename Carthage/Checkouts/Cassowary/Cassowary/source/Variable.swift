//
//  Variable.swift
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


/// use class will be easy to track the value of Variable
/// but using struct performent better than class type
public struct Variable{
  
  /// Variable type
  private enum VarType: CustomDebugStringConvertible {
    
    /// public variable
    case external
    
    /// variable used to normalize required equality,like expr = 0 to expr + d1 - d2 = 0
    case dummpy
    
    /// variable for inequality,used to normalize expr like expr <= 0 to expr == slack
    case slack
    
    /// Varable for objective function
    case error
    
    var debugDescription: String{
      switch self {
      case .external: return "v"
      case .dummpy: return "d"
      case .slack: return "s"
      case .error: return "e"
      }
    }
  }
  
  var isDummy: Bool {
    return self.varType == .dummpy
  }
  
  var isExternal: Bool {
    return varType == .external
  }
  
  var isSlack: Bool{
    return varType == .slack
  }
  
  var isError: Bool{
    return varType == .error
  }
  
  var isPivotable: Bool {
    return varType == .slack || varType == .error
  }
  
  var isRestricted: Bool {
    return varType != .external
  }
  
  public init(value: Double = 0) {
    self.init(type: .external)
  }
  
  private init(type: VarType){
    self.varType = type
    Variable.count += 1
    count = Variable.count
  }
  
  static func slack() -> Variable{
    return Variable(type: .slack)
  }
  
  static func dummpy() -> Variable{
    return Variable(type: .dummpy)
  }
  
  static func error() -> Variable{
    return Variable(type: .error)
  }
  
  /// used for debug print
  fileprivate let count: Int
  private static var count = 0
  private let varType: VarType
}

extension Variable: CustomDebugStringConvertible{
  public var debugDescription: String{
    return "\(varType)" + "\(count)"
  }
}

extension Variable: Hashable{
  
  public static func ==(lhs: Variable, rhs: Variable) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }

  public var hashValue: Int{
    return count
  }
}

