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
	var sqlVc : SqlViewController? = nil

    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		sqlVc = SqlViewController()
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

		sqlVc = nil
    }

	func testTypeOneChar()
	{
		guard let vc : SqlViewController = sqlVc
		else
		{
			XCTFail()
			return
		}

		let editRange : Range<Int> = 0..<1
		vc.updateSqlStatements(processedText : "s", editedRange : editRange, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 1)
		XCTAssertEqual(editRange, vc.currentStatement.statementRange)
	}

	func testTypeMultipleChar()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "s", editedRange : 0..<1, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 1)
		vc.updateSqlStatements(processedText : "se", editedRange : 1..<2, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 2)
		vc.updateSqlStatements(processedText : "sel", editedRange : 2..<3, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 3)
		vc.updateSqlStatements(processedText : "sele", editedRange : 3..<4, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		vc.updateSqlStatements(processedText : "selec", editedRange : 4..<5, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 5)
		vc.updateSqlStatements(processedText : "select", editedRange : 5..<6, lastDelta : 1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(0..<6, vc.currentStatement.statementRange)
	}

	func testTypeMultipleCharBurst()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : 0..<6, lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(0..<6, vc.currentStatement.statementRange)
	}

	func testDeleteOneChar()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "drop", editedRange : 0..<4, lastDelta : 4)

		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		XCTAssertEqual(0..<4, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "dro", editedRange : 3..<3, lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 3)
		XCTAssertEqual(0..<3, vc.currentStatement.statementRange)
	}

	func testDeleteMultipleChar()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "dropped", editedRange : 0..<7, lastDelta : 7)

		XCTAssertEqual(vc.currentStatement.statementText.count, 7)
		XCTAssertEqual(0..<7, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "droppe", editedRange : 6..<6, lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(0..<6, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "dropp", editedRange : 5..<5, lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 5)
		XCTAssertEqual(0..<5, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "drop", editedRange : 4..<4, lastDelta : -1)
		XCTAssertEqual(vc.currentStatement.statementText.count, 4)
		XCTAssertEqual(0..<4, vc.currentStatement.statementRange)
	}

	func testTypeOneWord()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : 0..<6, lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(0..<6, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "select ", editedRange : 6..<7, lastDelta : 1)
		XCTAssertEqual(0..<7, vc.currentStatement.statementRange)
		XCTAssertEqual(1, vc.currentStatement.wordCount)
	}

	func testTypeMultipleWords()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)
		vc.updateSqlStatements(processedText : "select", editedRange : 0..<6, lastDelta : 6)

		XCTAssertEqual(vc.currentStatement.statementText.count, 6)
		XCTAssertEqual(0..<6, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText : "select ", editedRange : 6..<7, lastDelta : 1)
		XCTAssertEqual(0..<7, vc.currentStatement.statementRange)
		XCTAssertEqual(1, vc.currentStatement.wordCount)

		vc.updateSqlStatements(processedText: "select * ", editedRange: 7..<9, lastDelta: 2)
		XCTAssertEqual(0..<9, vc.currentStatement.statementRange)
		XCTAssertEqual(2, vc.currentStatement.wordCount)
	}

	func testDeleteWord()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: 0..<24, lastDelta: 24)
		XCTAssertEqual(0..<24, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select * from ", editedRange: 0..<14, lastDelta: -10)
		XCTAssertEqual(0..<14, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 14)
		XCTAssertEqual(vc.currentStatement.wordCount, 3)

		vc.updateSqlStatements(processedText: "select * ", editedRange: 0..<9, lastDelta: -5)
		XCTAssertEqual(0..<9, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 9)
		XCTAssertEqual(vc.currentStatement.wordCount, 2)
	}

	func testPartialWordDelete()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(0..<0, vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: 0..<24, lastDelta: 24)
		XCTAssertEqual(0..<24, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select * from Test", editedRange: 0..<18, lastDelta: -6)
		XCTAssertEqual(0..<18, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 18)
		XCTAssertEqual(vc.currentStatement.wordCount, 3)

		vc.updateSqlStatements(processedText: "select * fr", editedRange: 0..<11, lastDelta: -7)
		XCTAssertEqual(0..<11, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 11)
		XCTAssertEqual(vc.currentStatement.wordCount, 2)
	}

	func testMidStreamInsert()
	{
		guard let vc : SqlViewController = sqlVc
			else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(Range<Int>(0..<0), vc.currentStatement.statementRange)

		vc.updateSqlStatements(processedText: "select * from TestTable;", editedRange: 0..<24, lastDelta: 24)
		XCTAssertEqual(0..<24, vc.currentStatement.statementRange)
		XCTAssertEqual(vc.currentStatement.statementText.count, 24)
		XCTAssertEqual(vc.currentStatement.wordCount, 4)

		vc.updateSqlStatements(processedText: "select t from TestTable;", editedRange: 7..<8, lastDelta: 0)
	}
}
