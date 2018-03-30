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
		let editRange : Range<Int> = 0..<1
		vc.updateSqlStatements(processedText : "s", editedRange : editRange, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 1)
		XCTAssertEqual(editRange, vc.currentStatement.statementRange)
	}

	func testTypeMultipleChar()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "s", editedRange : Range<Int>(0..<1), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 1)
		vc.updateSqlStatements(processedText : "se", editedRange : Range<Int>(1..<2), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 2)
		vc.updateSqlStatements(processedText : "sel", editedRange : Range<Int>(2..<3), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 3)
		vc.updateSqlStatements(processedText : "sele", editedRange : Range<Int>(3..<4), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		vc.updateSqlStatements(processedText : "selec", editedRange : Range(4..<5), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 5)
		vc.updateSqlStatements(processedText : "select", editedRange : Range<Int>(5..<6), lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(Range(0..<6), vc.currentStatement.statementRange)
	}

	func testTypeMultipleCharBurst()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : Range(0..<6), lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(Range<Int>(0..<6), vc.currentStatement.statementRange)
	}

	func testDeleteOneChar()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "drop", editedRange : Range(0..<4), lastDelta : 4)

		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		XCTAssertEqual(Range<Int>(0..<4), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "dro", editedRange : Range<Int>(3..<3), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 3)
		XCTAssertEqual(Range<Int>(0..<3), vc.currentStatement.statementRange)
	}

	func testDeleteMultipleChar()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "dropped", editedRange : Range<Int>(0..<7), lastDelta : 7)

		XCTAssertEqual(vc.currentStatement.statementText.count, 7)
		XCTAssertEqual(Range<Int>(0..<7), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "droppe", editedRange : Range<Int>(6..<6), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(Range<Int>(0..<6), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "dropp", editedRange : Range<Int>(5..<5), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 5)
		XCTAssertEqual(Range<Int>(0..<5), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "drop", editedRange : Range<Int>(4..<4), lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		XCTAssertEqual(Range<Int>(0..<4), vc.currentStatement.statementRange)
	}

	func testTypeOneWord()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : Range<Int>(0..<6), lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(Range<Int>(0..<6), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "select ", editedRange : Range<Int>(6..<7), lastDelta : 1)
		XCTAssertEqual(Range<Int>(0..<7), vc.currentStatement.statementRange)
		XCTAssertEqual(1, vc.currentStatement.wordCount)
	}

	func testTypeMultipleWords()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : Range<Int>(0..<6), lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(Range<Int>(0..<6), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "select ", editedRange : Range<Int>(6..<7), lastDelta : 1)
		XCTAssertEqual(Range<Int>(0..<7), vc.currentStatement.statementRange)
		XCTAssertEqual(1, vc.currentStatement.wordCount)

		vc.updateSqlStatements(processedText: "select * ", editedRange: Range(7..<9), lastDelta: 2)
		XCTAssertEqual(Range<Int>(0..<9), vc.currentStatement.statementRange)
		XCTAssertEqual(2, vc.currentStatement.wordCount)
	}

	func testDeleteWord()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: Range<Int>(0..<24), lastDelta: 24)
		XCTAssertEqual(Range<Int>(0..<24), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select * from ", editedRange: Range(0..<14), lastDelta: -10)
		XCTAssertEqual(Range<Int>(0..<14), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 14)
		XCTAssertEqual(vc.currentStatement.wordCount, 3)

		vc.updateSqlStatements(processedText: "select * ", editedRange: Range<Int>(0..<9), lastDelta: -5)
		XCTAssertEqual(Range<Int>(0..<9), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 9)
		XCTAssertEqual(vc.currentStatement.wordCount, 2)
	}

	func testPartialWordDelete()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: Range<Int>(0..<24), lastDelta: 24)
		XCTAssertEqual(Range<Int>(0..<24), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select * from Test", editedRange: Range<Int>(0..<18), lastDelta: -6)
		XCTAssertEqual(Range<Int>(0..<18), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 18)
		XCTAssertEqual(vc.currentStatement.wordCount, 3)

		vc.updateSqlStatements(processedText: "select * fr", editedRange: Range<Int>(0..<11), lastDelta: -7)
		XCTAssertEqual(Range<Int>(0..<11), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 11)
		XCTAssertEqual(vc.currentStatement.wordCount, 2)
	}

	func testMidStreamInsert()
	{
		let vc = SqlViewController()
		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: Range<Int>(0..<24), lastDelta: 24)
		XCTAssertEqual(Range<Int>(0..<24), vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select t from TestTable;", editedRange: Range<Int>(7..<8), lastDelta: 0)
	}
}
