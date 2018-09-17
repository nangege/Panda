//
//  LayoutableTests.swift
//  LayoutableTests
//
//  Created by nangezao on 2018/8/31.
//  Copyright © 2018 Tang Nan. All rights reserved.
//

import XCTest
@testable import Layoutable

class LayoutableTests: XCTestCase {

    override func setUp() {
      let test = TestNode()
      test.size == (320,640)
      test.layoutIfEnabled()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
      let node = TestNode()
      let node1 = TestNode()
      let node2 = TestNode()
      
      node.addSubnode(node1)
      node.addSubnode(node2)
      
      node1.size == (30,30)
      node2.size == (40,40)
      
      [node,node1].equal(.centerY,.left)
      
      [node2,node].equal(.top,.bottom,.centerY,.right)
      
      [node1,node2].space(10, axis: .horizontal)
      let c =  node.left == node2.left + 10
      c.constant = 100
      node.layoutIfEnabled()
      
      print(node.frame)
      print(node1.frame)
      print(node2.frame)
    }

    func testNestPerformance() {
        let testNumber = 100
        self.measure {
          let node = TestNode()
          var nodes = [TestNode]()
          node.size == (320.0,640.0)
          for index in 0..<testNumber{
            
            let newNode = TestNode()
            if nodes.count == 0{
              node.addSubnode(newNode)
              newNode.edge == node + (0.5,0.5,0.5,0.5)
            }else{
              let aNode = nodes[index - 1]
              aNode.addSubnode(newNode)
              newNode.edge == aNode + (1,1,1,1)
            }
            nodes.append(newNode)
          }
          node.layoutIfEnabled()
        }
    }
  
  func testAutolayoutPerformance() {
    let testNumber = 100
    self.measure {
      let node = TestNode()
      var nodes = [TestNode]()
      node.size == (320.0,640.0)
      for _ in 0..<testNumber{
        var leftNode = node
        var rightNode = node
        if nodes.count != 0{
          let left = Int(arc4random())%nodes.count
          let right = Int(arc4random())%nodes.count
          leftNode = nodes[left]
          rightNode = nodes[right]
        }
        
        let newNode = TestNode()
        node.addSubnode(newNode)
        
        newNode.left >= 0
        newNode.right <= node.right
        
        newNode.top >= 20
        newNode.bottom <= node.bottom - 20
        
        newNode.left == leftNode.left + CGFloat(arc4random()%20)
        node.top == rightNode.top + CGFloat(arc4random()%20)

        nodes.append(newNode)
      }
      node.layoutIfEnabled()
    }
  }

}
