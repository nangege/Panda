//
//  SimpleSolver.swift
//  Cassowary
//
//  Created by nangezao on 2017/10/22.
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

public enum ConstraintError: Error{
  case requiredFailure
  case objectiveUnbound
  case constraintNotFound
  case internalError(String)
  case requiredFailureWithExplanation([Constraint])
}

fileprivate typealias VarSet = Set<Variable>
fileprivate typealias Row = [Variable: Expression]

final public class SimplexSolver{
  
  // whether call solve() when add or remove constraint
  // if false ,remeber to call solve() to get right result
  public var autoSolve = false
  
  public var explainFailure = true

  private var rows = Row()
  
  // used to record infeasible rows when edit constarint
  // which means marker of this row is not external variable,but constant of expr < 0
  // we need to optimize this later
  private var infeasibleRows = VarSet()
  
  private var constraintMarkered = [Variable: Constraint]()
  
  // mapper for constraint and marker variable
  private var markerVars = [Constraint: Variable]()
  private var errorVars = [Constraint: VarSet]()
  
  //objective function,out goal is to minimize this function
  private var objective = Expression()
  
  public init() {}
  
  public func add(constraint: Constraint) throws{
    let expr = expression(for: constraint)
    let addedOKDirectly = tryToAdd(expr: expr)
    if !addedOKDirectly{
      let result = try addArtificalVariable(to: expr)
      if !result.0{
        try remove(constraint: constraint)
        throw ConstraintError.requiredFailureWithExplanation(result.1)
      }
    }
    if autoSolve{
      try solve()
    }
  }
  
  public func remove(constraint: Constraint) throws {
    
    guard let marker =  markerVars[constraint] else{
      throw ConstraintError.constraintNotFound
    }
    
    // remove errorVar from objective function
    errorVars[constraint]?.forEach{
      add(expr: objective, variable: $0, delta: -constraint.weight)
      removeRow(for: $0)
    }
    
    markerVars.removeValue(forKey: constraint)
    errorVars.removeValue(forKey: constraint)
    constraintMarkered.removeValue(forKey: marker)
    
    if !isBasicVar(marker){
      
      if let exitVar = findExitVar(for: marker){
        pivot(entry: marker, exit: exitVar)
      }
    }
    
    if isBasicVar(marker){
      removeRow(for: marker)
    }

    if autoSolve{
      try solve()
    }
  }
  
  /// update constant for constraint to value
  ///
  /// - Parameters:
  ///   - constraint: constraint to update
  ///   - value: target constant
  public func updateConstant(for constraint: Constraint,to value: Double){
    assert(markerVars.keys.contains(constraint))
  
    let delta = -(value + constraint.expression.constant)
    if approx(a: delta, b: 0){
      return
    }
    editConstant(for: constraint, delta: delta)
    constraint.updateConstant(to: value)
    resolve()
  }
  
  /// update strength for constraint
  /// required constraint is not allowed to modify
  /// - Parameters:
  ///   - constraint: constraint to update
  ///   - strength: target strength
  public func updateStrength(for constraint: Constraint, to strength: Strength) throws{
    if constraint.strength == strength{
      return
    }
    
    guard let errorVars = errorVars[constraint] else{
      return
    }
    
    let delta = strength.rawValue - constraint.weight
    constraint.strength = strength
    
    // strength only affact objective function
    errorVars.forEach {
      add(expr: objective, variable: $0, delta: delta)
    }
    
    if autoSolve{
      try solve()
    }
  }
  
  /// solver this simplex problem
  public func solve() throws{
    try optimize(objective)
  }
  
  private func resolve(){
    _ = try? dualOptimize()
    infeasibleRows.removeAll()
  }
  
  public func valueFor(_ variable: Variable) -> Double{
    if let constant = rows[variable]?.constant{
      return constant
    }
    return 0
  }
  
  /// optimize objective function,minimize expr
  /// objective = a1*s1 + a2 * s2 + a3 * e3 + a4 * e4 ...+ an*(sn,or en)
  /// if s(i) is not basic, it will be treated as 0
  /// so if coefficient a of s or e is less than 0, make s to becomne basic,
  //  this will increase value of s, decrease the value of expr
  /// - Parameter row: expression to optimize
  /// - Throws:
  private func optimize(_ row: Expression) throws{
    var entry: Variable? = nil
    var exit: Variable? = nil
    
    while true {
      entry = nil
      exit = nil

      for (v, c) in row.terms{
        if v.isPivotable && c < 0{
          entry = v
          break
        }
      }
      
      guard let entry = entry else{
        return
      }

      var minRadio = Double.greatestFiniteMagnitude
      var r = 0.0
      
      for (v , expr) in rows{
        if !v.isPivotable{
          continue
        }

        let coeff = expr.coefficient(for: entry)
        
        if coeff >= 0{
          continue
        }
        
        r = -expr.constant/coeff
        
        if r < minRadio{
          minRadio = r
          exit = v
        }
      }
  
      if minRadio == .greatestFiniteMagnitude{
        throw ConstraintError.objectiveUnbound
      }
      if let exit = exit{
        pivot(entry: entry, exit: exit)
      }
    }
  }
  
  private func dualOptimize() throws{
    while !infeasibleRows.isEmpty {
      let exitVar = infeasibleRows.removeFirst()
      
      if !isBasicVar(exitVar){
        continue
      }
      
      let expr = rowExpression(for: exitVar)
      if expr.constant >= 0{
        continue
      }
      
      var ratio = Double.greatestFiniteMagnitude
      var r = 0.0
      var entryVar: Variable? = nil
      
      for (v, c) in expr.terms{
        if c > 0 && v.isPivotable{
          r = objective.coefficient(for: v)/c
          if r < ratio{
            entryVar = v
            ratio = r
          }
        }
      }
      
      guard let entry = entryVar else{
        throw  ConstraintError.internalError("dual_optimize: no pivot found")
      }
      
      pivot(entry: entry, exit: exitVar)
    }
    
  }
  
  
  /// exchange basic var and parametic var
  /// example: row like rows[x] = 2*y + z which means x = 2*y + z, pivot(entry: z, exit: x)
  /// result: rows[y] = 1/2*x - 1/2*z which is y = 1/2*x - 1/2*z
  /// - Parameters:
  ///   - entry: variable to become basic var
  ///   - exit: variable to exit from basic var
  private func pivot(entry: Variable, exit: Variable){
    let expr = removeRow(for: exit)
    expr.changeSubject(from: exit, to: entry)
    substituteOut(old: entry, expr: expr)
    addRow(variable: entry, expr: expr)
  }
  
  
  /// try to add expr to tableu
  /// - Parameter expr: expression to add
  /// - Returns: if we can't find a variable in expr to become basic, return false; else return true
  private func tryToAdd(expr: Expression) -> Bool{
    guard let subject = chooseSubject(expr: expr) else{
      return false
    }
    expr.solve(for: subject)
    substituteOut(old: subject, expr: expr)
    addRow(variable: subject, expr: expr)
    return true
  }
  
  
  /// choose a subject to become basic var from expr
  /// if expr constains external variable, return external variable
  /// if expr doesn't contain external, find a slack or error var which has a negtive coefficient
  /// else return nil
  /// - Parameter expr: expr to choose subject from
  /// - Returns: subject to become basic
  private func chooseSubject(expr: Expression) -> Variable?{
    
    var subject: Variable? = nil
    for (variable,coeff) in expr.terms{
      if variable.isExternal{
        return variable
      }else if variable.isPivotable && coeff < 0{
        subject = variable
      }
    }
    return subject
  }
  
  
  private func addArtificalVariable(to expr: Expression) throws -> (Bool,[Constraint]) {
    let av = Variable.slack()
    //let row = Expression(expr: expr)
    
    addRow(variable: av, expr: expr)

    try optimize(expr)
    
    if !nearZero(expr.constant){
  
      if explainFailure{
        return (false, buildExplanation(for: av, row: expr))
      }
      return (false, [Constraint]())
    }
    
    if isBasicVar(av){
      let expr = rowExpression(for: av)
      
      if expr.isConstant{
        assert(nearZero(expr.constant))
        removeRow(for: av)
        return (true, [Constraint]())
      }
    
      guard let entry = expr.pivotableVar else{
        var result = [Constraint]()
        if explainFailure{
          result = buildExplanation(for: av, row: expr)
        }
        return (false, result)
      }
      pivot(entry: entry, exit: av)
    }
  
    assert(!isBasicVar(av))
  
    return (true, [Constraint]())
  }
  
  private func buildExplanation(for marker: Variable, row: Expression) -> [Constraint]{
    var explanation = [Constraint]()
    
    if let constraint = constraintMarkered[marker]{
      explanation.append(constraint)
    }
    
    for variable in row.terms.keys{
      if let constraint = constraintMarkered[variable]{
        explanation.append(constraint)
      }
    }
    
    return explanation
  }
  
  
  /// make a new linear expression to represent constraint
  /// this will replace all basic var in constraint.expr with related expression
  /// add slack and dummpy var if necessary
  /// - Parameter constraint: constraint to be represented
  private func expression(for constraint: Constraint) -> Expression{
    
    let expr = Expression()

    let cexpr = constraint.expression
    expr.constant = cexpr.constant
    
    for term in cexpr.terms{
      add(expr: expr, variable: term.key, delta: term.value)
    }
    
    if constraint.isInequality{
      // if is Inequality,add slack var
      // expr <(>)= 0 to expr - slack = 0
      let slack = Variable.slack()
      expr -= slack
      markerVars[constraint] = slack
      constraintMarkered[slack] = constraint
      
      if !constraint.isRequired{
        let minus = Variable.error()
        expr += minus
        objective += minus * constraint.weight
        
        addError(minus, for: constraint)
      }
    }else{
      if constraint.isRequired{
        let dummp = Variable.dummpy()
        expr -= dummp

        markerVars[constraint] = dummp
        constraintMarkered[dummp] = constraint
      }else{
        let eplus = Variable.error()
        let eminus = Variable.error()
        expr -= eplus
        expr += eminus
        
        markerVars[constraint] = eplus
        constraintMarkered[eplus] = constraint
        
        objective += eplus*constraint.weight
        addError(eplus, for: constraint)
      
        objective += eminus * constraint.weight
        addError(eminus, for: constraint)
      }
    }
    
    if expr.constant < 0{
      expr *= -1
    }
    return expr
  }
  
  
  private func editConstant(for constraint: Constraint,delta value: Double){
    let marker = markerVars[constraint]!
    var delta = value
    if marker.isSlack || constraint.isRequired{
      if constraint.relation == .greateThanOrEqual{
        delta = -delta
      }
    }

    if isBasicVar(marker){
      let expr = rowExpression(for: marker)
      expr.increaseConstant(by: -delta)
      if expr.constant < 0{
        infeasibleRows.insert(marker)
      }
    }else{
      for (v, expr) in rows{
        expr.increaseConstant(by: expr.coefficient(for: marker)*delta)
        if !v.isExternal && expr.constant < 0{
          infeasibleRows.insert(v)
        }
      }
    }
  }
  
  private func addError(_ v: Variable ,for constraint: Constraint){
    if  errorVars[constraint] != nil{
      errorVars[constraint]?.insert(v)
    }else{
      var errors = VarSet()
      errors.insert(v)
      errorVars[constraint] = errors
    }
  }
  
  private func rowExpression(for v: Variable) -> Expression{
    assert(rows.keys.contains(v))
    return rows[v]!
  }
  
  
  /// find a variable to exit from basic var
  /// this will travese all rows contains v
  /// choose one that coefficient
  /// - Returns: variable to become parametic
  private func findExitVar(for v: Variable) -> Variable?{
    
    var minRadio1 = Double.greatestFiniteMagnitude
    var minRadio2 = Double.greatestFiniteMagnitude
    var exitVar1: Variable? = nil
    var exitVar2: Variable? = nil
    var exitVar3: Variable? = nil
    
    for (variable, expr) in rows{
      let c = expr.coefficient(for: v)
      if c == 0{
        continue
      }
      
      if variable.isExternal{
        exitVar3 = variable
      }
      else if c < 0{
        let r = -expr.constant/c
        if r < minRadio1{
          minRadio1 = r
          exitVar1 = variable
        }
      }else{
        let r = -expr.constant/c
        if r < minRadio2{
          minRadio2 = r
          exitVar2 = variable
        }
      }
    }
    
    var exitVar = exitVar1
    if exitVar == nil{
      if exitVar2 == nil{
        exitVar = exitVar3
      }else{
        exitVar = exitVar2
      }
    }
    return exitVar
  }
  
  // add delta*variable to expr
  // if variable is basicVar, replace variable with expr
  private func add(expr: Expression, variable: Variable, delta: Double){
    if isBasicVar(variable){
      let row = rowExpression(for: variable)
      expr.add(expr: row ,multiply: delta)
    }else{
      expr.add(variable, multiply: delta)
    }
  }
  
  private  func addRow(variable: Variable, expr: Expression){
    rows[variable] = expr
  }
  
  @discardableResult private func removeRow(for v: Variable) -> Expression{
    assert(rows.keys.contains(v))
    infeasibleRows.remove(v)
    return rows.removeValue(forKey: v)!
  }
  
  /// replace all old variable in rows and objective function with expr
  /// such as if one row = x + 2*y + 3*z, expr is  5*m + n
  /// after substitutionOut(old: y, expr: expr),row = x + 10*m + 2*n + 3*z
  /// - Parameters:
  ///   - old: variable to be replaced
  ///   - expr: expression to replace
  private  func substituteOut(old: Variable, expr: Expression){
    for (v ,rowExpr) in rows{
      if rowExpr.terms.keys.contains(old){
        rowExpr.substituteOut(old, with: expr)
        if v.isRestricted && rowExpr.constant < 0{
          infeasibleRows.insert(v)
        }
      }
    }
    objective.substituteOut(old, with: expr)
  }
  
  /// check vhether variable is a basic Variable
  /// basic var means variable only appear in rows.keys
  /// - Parameter vairable: variable to be checked
  /// - Returns: whether variable is a basic var
  private func isBasicVar(_ vairable: Variable) -> Bool{
    return rows.keys.contains(vairable)
  }
  
  public func printRow(){
    print("=============== ROW ===============")
    print("objctive = \(objective)")
    for (v, expr) in rows{
      print("V: \(v) = \(expr)")
    }
  }
  
}
