//
//  SimplexSolverTestCase.swift
//  CassowaryTests
//
//  Created by nangezao on 2018/8/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Cassowary

class SimplexSolverTestCase: XCTestCase {

  let solver = SimplexSolver()
  
  override func setUp() {
    solver.autoSolve = true
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let var1 = Variable()
    let var2 = Variable()
    try? solver.add(constraint: var1 == var2 )
    try? solver.add(constraint: var1 == 100)
    
    XCTAssert(solver.valueFor(var1) == 100.0)
    XCTAssert(solver.valueFor(var2) == 100.0)
  }
  
  func testSetConstant(){
    let solver = SimplexSolver()
    solver.autoSolve = true
    let var1 = Variable()
    let c = var1 == 100
    try? solver.add(constraint: c)
    XCTAssert(solver.valueFor(var1) == 100)
    solver.updateConstant(for: c, to: 150)
    XCTAssert(solver.valueFor(var1) == 150)
    solver.updateConstant(for: c, to: 0)
    XCTAssert(solver.valueFor(var1) == 0)
    solver.updateConstant(for: c, to: -20)
    XCTAssert(solver.valueFor(var1) == -20)
  }
  
  func testChangeStrength(){
    let solver = SimplexSolver()
    solver.autoSolve = true
    
    let v1 = Variable()
    let c1 = v1 == 100
    let c2 = v1 == 150
    
    c1.strength = .strong
    c2.strength = .medium
    
    try? solver.add(constraint: c1)
    try? solver.add(constraint: c2)
    XCTAssertEqual(solver.valueFor(v1), 100)
    
    try? solver.updateStrength(for: c1, to: .weak)
    
    XCTAssertEqual(solver.valueFor(v1), 150)
    
  }

}
