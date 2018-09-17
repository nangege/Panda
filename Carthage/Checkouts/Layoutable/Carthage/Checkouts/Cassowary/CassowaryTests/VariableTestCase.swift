//
//  VariableTestCase.swift
//  CassowaryTests
//
//  Created by nangezao on 2018/8/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Cassowary

class VariableTestCase: XCTestCase {

  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testExternal() {
    let v1 = Variable()
    XCTAssert(v1.isExternal)
    XCTAssertFalse(v1.isDummy)
    XCTAssertFalse(v1.isError)
    XCTAssertFalse(v1.isPivotable)
    XCTAssertFalse(v1.isRestricted)
    XCTAssertFalse(v1.isSlack)
  }
  
  func testSlack(){
    let v1 = Variable.slack()
    XCTAssertFalse(v1.isExternal)
    XCTAssertFalse(v1.isDummy)
    XCTAssertFalse(v1.isError)
    XCTAssert(v1.isPivotable)
    XCTAssert(v1.isRestricted)
    XCTAssert(v1.isSlack)
  }
  
  func testDummpy(){
    let v1 = Variable.dummpy()
    XCTAssertFalse(v1.isExternal)
    XCTAssert(v1.isDummy)
    XCTAssertFalse(v1.isError)
    XCTAssertFalse(v1.isPivotable)
    XCTAssert(v1.isRestricted)
    XCTAssertFalse(v1.isSlack)
  }
  
  func testError(){
    let v1 = Variable.error()
    XCTAssertFalse(v1.isExternal)
    XCTAssertFalse(v1.isDummy)
    XCTAssert(v1.isError)
    XCTAssert(v1.isPivotable)
    XCTAssert(v1.isRestricted)
    XCTAssertFalse(v1.isSlack)
  }
}
