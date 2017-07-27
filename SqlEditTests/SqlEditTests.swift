//
//  SqlEditTests.swift
//  SqlEditTests
//
//  Created by Mark Hoggatt on 28/05/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import XCTest
@testable import SqlEdit

class SqlEditTests: XCTestCase
{
    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	func testTypeOneChar()
	{
		let vc = SqlViewController()
		let editRange = NSMakeRange(0, 1)
		vc.updateSqlStatements(processedText : "s", editedRange : editRange, lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 1)
		assert(NSEqualRanges(editRange, vc.currentStatement.statementRange) == true)
	}

	func testTypeMultipleChar()
	{
		let vc = SqlViewController()
		assert(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange) == true)
		vc.updateSqlStatements(processedText : "s", editedRange : NSMakeRange(0, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 1)
		vc.updateSqlStatements(processedText : "se", editedRange : NSMakeRange(1, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 2)
		vc.updateSqlStatements(processedText : "sel", editedRange : NSMakeRange(2, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 3)
		vc.updateSqlStatements(processedText : "sele", editedRange : NSMakeRange(3, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 4)
		vc.updateSqlStatements(processedText : "selec", editedRange : NSMakeRange(4, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 5)
		vc.updateSqlStatements(processedText : "select", editedRange : NSMakeRange(5, 1), lastDelta : 1)
		assert(vc.currentStatement.statementText.characters.count == 6)
		assert(NSEqualRanges(NSMakeRange(0, 6), vc.currentStatement.statementRange) == true)
	}
    
    func testPerformanceExample()
	{
        // This is an example of a performance test case.
        self.measure
		{
            // Put the code you want to measure the time of here.
        }
    }
    
}
