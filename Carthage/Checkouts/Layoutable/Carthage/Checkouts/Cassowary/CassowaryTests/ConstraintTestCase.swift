//
//  ConstraintTestCase.swift
//  CassowaryTests
//
//  Created by nangezao on 2018/8/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Cassowary

class ConstraintTestCase: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testStrength() {
    XCTAssertEqual(Strength.required.rawValue, 1000.0)
    XCTAssertEqual(Strength.strong.rawValue, 750.0)
    XCTAssertEqual(Strength.medium.rawValue, 250.0)
    XCTAssertEqual(Strength.weak.rawValue, 10.0)
  }

}
