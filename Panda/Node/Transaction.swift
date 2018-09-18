//
//  Transaction.swift
//  Cassowary
//
//  Created by Tang,Nan(MAD) on 2018/2/28.
//  Copyright © 2018年 nange. All rights reserved.
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

func synchronized(lock: Any, closure: () -> ()) {
  objc_sync_enter(lock)
  closure()
  objc_sync_exit(lock)
}

protocol RunloopObserver: Hashable{
  func runLoopDidUpdate()
}

final class Transaction{
  
  private static var observerSet = Set<ViewNode>()
  
  class func addObserver(_ observer: ViewNode){
    /// runloop observer is only meaningful in main thread
    if Thread.isMainThread{
      StartObserver
      observerSet.insert(observer)
    }
  }
  
  /// just a meaningless static var to make this piece of code run only once
  private static let StartObserver: () = {
    let runLoop = RunLoop.main.getCFRunLoop()
    let activity: CFRunLoopActivity = [.beforeWaiting,.exit]
    var mutableSelf = Transaction.self
    var context = CFRunLoopObserverContext(version: 0, info: &mutableSelf, retain: nil, release: nil, copyDescription: nil)
    let observer =  CFRunLoopObserverCreate(kCFAllocatorDefault, activity.rawValue, true, 0, { (observer, activity, _) in
      
      synchronized(lock: Transaction.observerSet){
        if Transaction.observerSet.count == 0{
          return
        }
        let transactionSet = Transaction.observerSet
        Transaction.observerSet = Set<ViewNode>()
        
        transactionSet.forEach({
          $0.runLoopDidUpdate()
        })
      }

    }, &context)
    CFRunLoopAddObserver(runLoop, observer, .commonModes)
  }()
}


