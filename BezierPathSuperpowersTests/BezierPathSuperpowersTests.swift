//
//  BezierPathSuperpowersTests.swift
//  BezierPathSuperpowersTests
//
//  Created by Maximilian Kraus on 01.02.18.
//  Copyright © 2018 Maximilian Kraus. All rights reserved.
//

import XCTest
import BezierPathSuperpowers

class BezierPathSuperpowersTests: XCTestCase {
  
  let bezierPath = NSBezierPath()
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    NSBezierPath.mx_calcuationSettings.lengthPrecision = .high
    NSBezierPath.mx_prepare()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testAddLine() {
    let targetPoint = NSPoint(x: 100, y: 0)
  
    bezierPath.line(to: targetPoint)
    
    XCTAssert(bezierPath.mx_length == 100)
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    let path = NSBezierPath()
    path.move(to: .zero)
    path.line(to: NSPoint(x: 150, y: 0))
    path.relativeLine(to: NSPoint(x: 0, y: 150))
    
    XCTAssert(path.mx_length == 300)
  }
  
  func testPerformanceExample() {
    let path = NSBezierPath()
    path.move(to: .zero)
    path.line(to: NSPoint(x: 150, y: 0))
    path.relativeLine(to: NSPoint(x: 0, y: 150))
    // This is an example of a performance test case.
    self.measure {
      let p = path.mx_point(atFractionOfLength: 0.5)
      print(p)
      // Put the code you want to measure the time of here.
    }
  }
  
}
