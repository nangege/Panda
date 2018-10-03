//
//  ViewController.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2017/7/24.
//  Copyright © 2017年 nange. All rights reserved.
//

import XCTest

@testable import Panda

@testable import Layoutable

class PerformanceTests: XCTestCase {
  
  func testAutolayout() {

    for count in [/*5,10,20,30,40,50,60,70,*/100/*,200*/]{
      self.measure {
        autoLayout(count)
      }
    }

  }
  
  func testViewLayout(){
    for count in [/*5,10,20,30,40,50,60,70,*/100/*,200*/]{
      self.measure {
        viewLayout(count)
      }
    }
  }
  
  func testNestAutolayout(){
    nestAutoLayout(100)
  }
  
  func testNestViewLayout(){

    self.measure {
      nestView(100)
    }
  }
  
  func testNestNode(){
    self.measure {
      nestNode(100)
    }
  }
  
  func testNodeLayout(){
    self.measure {
      nodelayout(100)
    }
  }

}

extension PerformanceTests{
  func nestNode(_ testNumber: Int = 100) {
    let node = ViewNode()
    var nodes = [ViewNode]()
    node.size == (320.0,640.0)
    for index in 0..<testNumber{
      
      let newNode = ViewNode()
      if nodes.count == 0{
        node.addSubnode(newNode)
        newNode.edge == node + (0.5,0.5,0.5,0.5)
      }else{
        let aNode = nodes[index - 1]
        aNode.addSubnode(newNode)
        newNode.edge == aNode.edge.insets((1,1,1,1))
      }
      nodes.append(newNode)
    }
    node.layoutIfEnabled()
  }
  
  func nestView(_ testNumber: Int = 100) {
    
    let node = UIView()
    var nodes = [UIView]()
    node.size == (320.0,640.0)
    for index in 0..<testNumber{
      
      let newNode = UIView()
      if nodes.count == 0{
        node.addSubview(newNode)
        newNode.edge == node + (0.5,0.5,0.5,0.5)
      }else{
        let aNode = nodes[index - 1]
        aNode.addSubview(newNode)
        newNode.edge == aNode.edge.insets((1,1,1,1))
      }
      nodes.append(newNode)
    }
    node.layoutIfEnabled()
    
  }
  
  func nodelayout(_ testNumber: Int = 100) {
    
    let node = ViewNode()
    var nodes = [ViewNode]()
    node.size == (320.0,640.0)
    for _ in 0..<testNumber{
      var leftNode = node
      var rightNode = node
      if nodes.count != 0{
        let left = Int(arc4random()/2)%nodes.count
        let right = Int(arc4random()/2)%nodes.count
        leftNode = nodes[left]
        rightNode = nodes[right]
      }
      
      let newNode = ViewNode()
      node.addSubnode(newNode)
      
      newNode.left >= node.left
      newNode.right <= node.right
      
      newNode.top >= node.top + 20
      newNode.bottom <= node.bottom - 20
      
      newNode.left == leftNode.left + Double(arc4random()%20) ~ .strong
      newNode.top == rightNode.top + Double(arc4random()%20) ~ .strong
      
      nodes.append(newNode)
    }
    node.layoutIfEnabled()
    
  }
  
  func viewLayout(_ testNumber: Int = 100) {
    let container = UIView()
    let node = UIView()
    var nodes = [UIView]()
    node.size == (320.0,640.0)
    for _ in 0..<testNumber{
      var leftNode = node
      var rightNode = node
      if nodes.count != 0{
        let left = Int(arc4random()/2)%nodes.count
        let right = Int(arc4random()/2)%nodes.count
        leftNode = nodes[left]
        rightNode = nodes[right]
      }
      
      let newNode = UIView()
      node.addSubview(newNode)
      
      newNode.left >= node.left
      newNode.right <= node.right
      
      newNode.top >= node.top + 20
      newNode.bottom <= node.bottom - 20
      
      newNode.left == leftNode.left + Double(arc4random()%20) ~ .strong
      newNode.top == rightNode.top + Double(arc4random()%20) ~ .strong
      
      nodes.append(newNode)
    }
    node.layoutIfEnabled()
    container.addSubview(node)
  }
  
  func autoLayout(_ testNumber: Int = 100) {
    let container = UIView()
    let node = UIView()
    var nodes = [UIView]()
    node.widthAnchor.constraint(equalToConstant: 320).isActive = true
    node.heightAnchor.constraint(equalToConstant: 640).isActive = true
    node.translatesAutoresizingMaskIntoConstraints = false
    for _ in 0..<testNumber{
      var leftNode: UIView = node
      var rightNode: UIView = node
      if nodes.count != 0{
        let left = Int(arc4random()/2)%nodes.count
        let right = Int(arc4random()/2)%nodes.count
        leftNode = nodes[left]
        rightNode = nodes[right]
      }
      
      let newNode = UIView()
      newNode.translatesAutoresizingMaskIntoConstraints = false
      node.addSubview(newNode)
      
      NSLayoutConstraint.activate([
        newNode.leftAnchor.constraint(greaterThanOrEqualTo:node.leftAnchor , constant: 0),
        newNode.rightAnchor.constraint(lessThanOrEqualTo: node.rightAnchor),
        
        newNode.topAnchor.constraint(greaterThanOrEqualTo: node.topAnchor, constant: 20),
        newNode.bottomAnchor.constraint(lessThanOrEqualTo: node.bottomAnchor,constant: -20)])
      
      
      let c1 = newNode.leftAnchor.constraint(equalTo: leftNode.leftAnchor,constant: CGFloat(arc4random()%20))
      let c2 = newNode.topAnchor.constraint(equalTo: rightNode.topAnchor, constant: CGFloat(arc4random()%20))
      c1.priority = .defaultHigh
      c2.priority = .defaultHigh
      NSLayoutConstraint.activate([c1,c2])
      
      nodes.append(newNode)
    }
    container.addSubview(node)
    node.layoutIfNeeded()
  }
  
  func nestAutoLayout(_ testNumber: Int = 100) {
    
    var nodes = [UIView]()
    
    for index in 0..<testNumber{
      if nodes.count == 0{
        let node = UIView()
        node.frame = CGRect(x: 0, y: 0, width: 640, height: 480)
        nodes.append(node)
      }else{
        let node = UIView()
        let superNode = nodes[index - 1]
        superNode.addSubview(node)
        node.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          node.leftAnchor.constraint(greaterThanOrEqualTo:superNode.leftAnchor , constant: 1),
          node.rightAnchor.constraint(lessThanOrEqualTo: superNode.rightAnchor, constant: -1),
          
          node.topAnchor.constraint(greaterThanOrEqualTo: superNode.topAnchor, constant: 1),
          node.bottomAnchor.constraint(lessThanOrEqualTo: superNode.bottomAnchor,constant: -1)])
        
        nodes.append(node)
      }
      nodes[0].layoutIfNeeded()
    }
  }
}

