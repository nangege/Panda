//
//  ExpressionTestCase.swift
//  CassowaryTests
//
//  Created by nangezao on 2018/8/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Cassowary

class ExpressionTestCase: XCTestCase {

  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testInit(){
  
    let expr = Expression(constant: -5)
    XCTAssert(expr.isConstant)
    XCTAssertEqual(expr.constant ,-5)
    
    let v1 = Variable(), v2 = Variable()
    let expr2 = v1 * 2 - v2 + 1
    XCTAssertEqual(expr2.coefficient(for: v1), 2)
    XCTAssertEqual(expr2.coefficient(for: v2), -1)
    XCTAssertEqual(expr2.constant, 1)
    
    let expr3 = Expression(expr: expr2)
    XCTAssertEqual(expr3.coefficient(for: v1), 2)
    XCTAssertEqual(expr3.coefficient(for: v2), -1)
    XCTAssertEqual(expr3.constant, 1)
    
    
  }

  func testOperator() {
    let expr = Expression(constant: -5)
    
    expr *= -1
    XCTAssertEqual(expr.constant, 5)
   
    let v1 = Variable(value: 3),v2 = Variable(value: 2)
    let expr2 = v1 * 2 + 1
    
    expr2 += v1
    XCTAssertEqual(expr2.coefficient(for: v1), 3)
    expr2 -= v1
    XCTAssertEqual(expr2.coefficient(for: v1), 2)
    
    expr2 += 5
    XCTAssertEqual(expr2.constant, 6)
    
    expr2 -= 2
    XCTAssertEqual(expr2.constant, 4)
    
    expr2 += v2 * 5
    XCTAssertEqual(expr2.coefficient(for: v2), 5)
    
    expr2 /= 2
    XCTAssertEqual(expr2.coefficient(for: v1), 1)
    XCTAssertEqual(expr2.coefficient(for: v2), 2.5)
    XCTAssertEqual(expr2.constant, 2)
    
    let expr3 = Expression(expr: expr2)
    XCTAssertEqual(expr3.coefficient(for: v1), 1)
    XCTAssertEqual(expr3.coefficient(for: v2), 2.5)
    XCTAssertEqual(expr3.constant, 2)
  }
  
  func testSolve(){
    let x = Variable(), y = Variable(),z = Variable()
    let expr = 3 * x + 2 * y + z + 3
    expr.substituteOut(x, with: 2 * z + y + 3)  // 5 * y + 7 * z + 12
    XCTAssertEqual(expr.coefficient(for: y), 5)
    XCTAssertEqual(expr.coefficient(for: z), 7)
    XCTAssertEqual(expr.constant, 12)
    
    expr -= 4 * y
    expr -= 3 * z      // y + 4 * z + 12
    let coeff = expr.solve(for: y)     // y = -4 * z - 12
    XCTAssertEqual(coeff, 1)
    XCTAssertEqual(expr.coefficient(for: z), -4.0)
    XCTAssertEqual(expr.constant, -12.0)
    
    expr.changeSubject(from: y, to: z)   // z = -0.25 * y - 3
    XCTAssertEqual(expr.coefficient(for: y), -0.25)
    XCTAssertEqual(expr.coefficient(for: z), 0)
    XCTAssertEqual(expr.constant, -3)
    
    expr.earse(y)
    XCTAssertEqual(expr.coefficient(for: y), 0)
    
  }

}
