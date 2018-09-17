//
//  CassowaryTests.swift
//  CassowaryTests
//
//  Created by nangezao on 2018/8/26.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Cassowary

func uniformramdom() -> Double{
  return Double(arc4random()/2)/Double(RAND_MAX)
}

func grainedRand() -> Double{
  let grain = 1.0e-4
  return Double(Int(uniformramdom()/grain))*grain
}


class PerformanceTests: XCTestCase {
  
  let vars = (0..<500).map{ _ in return Variable()}
  
  var constraints = [Constraint]()
  
  let exprMaxVars: UInt32 = 3
  let constraintNumber = 500
  lazy var constraintMake = constraintNumber * 2
  let inEqualProb = 0.12

  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
    for _ in 0..<constraintMake{
      let expr = Expression(constant: grainedRand() * 20.0 - 10)
      let exprVarNumber = Int(uniformramdom()*Double(exprMaxVars)) + 1
      for _ in 0..<exprVarNumber{
        let index = Int(uniformramdom()*499)
        let variable = vars[index]
        expr += variable * (grainedRand() * 10.0 - 5.0)
      }
      
      if uniformramdom() < inEqualProb{
        constraints.append(expr <= 0)
      }else{
        constraints.append(expr == 0)
      }
    }
  }

  func testAddConstraintPerformance() {
    
    self.measure {
      
      let solvers = (0..<10).map{ _ in SimplexSolver()}
      solvers.forEach{ $0.autoSolve = true }
    
      var added = 0,eCount = 0
      for solver in solvers{
        added = 0
        eCount = 0
        for c in constraints{
          if added < constraintNumber{
            do{
              try solver.add(constraint: c)
              added += 1
            }catch{
              eCount += 1
            }

          }else{
            break
          }
        }
      }
    }
  }
  
  func testUpdateConstantPerformance(){
    let solver = SimplexSolver()
    solver.autoSolve = true
    
    var added = [Constraint]()
    
    for c in constraints{
      if added.count < constraintNumber{
        do{
          try solver.add(constraint: c)
          added.append(c)
        }catch{
          
        }
      }else{
        break
      }
    }
    

    self.measure {
      added.forEach{
        solver.updateConstant(for: $0, to:  grainedRand() * 20.0 - 10)
      }
    }
    
  }
  
  

}
