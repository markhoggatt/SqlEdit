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
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 1)
		XCTAssertTrue(NSEqualRanges(editRange, vc.currentStatement.statementRange))
	}

	func testTypeMultipleChar()
	{
		let vc = SqlViewController()
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange))
		vc.updateSqlStatements(processedText : "s", editedRange : NSMakeRange(0, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 1)
		vc.updateSqlStatements(processedText : "se", editedRange : NSMakeRange(1, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 2)
		vc.updateSqlStatements(processedText : "sel", editedRange : NSMakeRange(2, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 3)
		vc.updateSqlStatements(processedText : "sele", editedRange : NSMakeRange(3, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 4)
		vc.updateSqlStatements(processedText : "selec", editedRange : NSMakeRange(4, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 5)
		vc.updateSqlStatements(processedText : "select", editedRange : NSMakeRange(5, 1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 6)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 6), vc.currentStatement.statementRange))
	}

	func testTypeMultipleCharBurst()
	{
		let vc = SqlViewController()
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange))
		vc.updateSqlStatements(processedText : "select", editedRange : NSMakeRange(0, 6), lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 6)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 6), vc.currentStatement.statementRange))
	}

	func testDeleteOneChar()
	{
		let vc = SqlViewController()
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange))
		vc.updateSqlStatements(processedText : "drop", editedRange : NSMakeRange(0, 4), lastDelta : 4)

		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 4)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 4), vc.currentStatement.statementRange))

		vc.updateSqlStatements(processedText : "dro", editedRange : NSMakeRange(3, 0), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 3)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 3), vc.currentStatement.statementRange))
	}

	func testDeleteMultipleChar()
	{
		let vc = SqlViewController()
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange))
		vc.updateSqlStatements(processedText : "dropped", editedRange : NSMakeRange(0, 7), lastDelta : 7)

		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 7)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 7), vc.currentStatement.statementRange))

		vc.updateSqlStatements(processedText : "droppe", editedRange : NSMakeRange(6, 0), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 6)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 6), vc.currentStatement.statementRange))

		vc.updateSqlStatements(processedText : "dropp", editedRange : NSMakeRange(5, 0), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 5)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 5), vc.currentStatement.statementRange))

		vc.updateSqlStatements(processedText : "drop", editedRange : NSMakeRange(4, 0), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 4)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 4), vc.currentStatement.statementRange))
	}

	func testTypeOneWord()
	{
		let vc = SqlViewController()
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 0), vc.currentStatement.statementRange))
		vc.updateSqlStatements(processedText : "select", editedRange : NSMakeRange(0, 6), lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.characters.count, 6)
		XCTAssertTrue(NSEqualRanges(NSMakeRange(0, 6), vc.currentStatement.statementRange))

		vc.updateSqlStatements(processedText : "select ", editedRange : NSMakeRange(7, 1), lastDelta : 1)
	}
}
