//
//  SqlStatementTests.swift
//  SqlEditTests
//
//  Created by Mark Hoggatt on 14/07/2018.
//  Copyright © 2018 Code Europa. All rights reserved.
//

import XCTest
@testable import SqlEdit

class SqlStatementTests: XCTestCase
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

    func testAppendFirstCharacter()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "s", withRange: 0..<1)
		XCTAssertEqual(statement.statementText.count, 1)
		XCTAssertEqual(statement.wordCount, 0)
    }

	func testAppendOnlySpace()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: " ", withRange: 0..<1)
		XCTAssertEqual(statement.statementText.count, 1)
		XCTAssertEqual(statement.wordCount, 0)
	}

	func testAppendSecondCharacter()
	{
		let statement = SqlStatement(statement: "s")
		statement.appendChrsToStatement(nextChars: "e", withRange: 1..<2)
		XCTAssertEqual(statement.statementText.count, 2)
		XCTAssertEqual(statement.wordCount, 0)
	}

	func testAppendFirstBurst()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select", withRange: 0..<6)
		XCTAssertEqual(statement.statementText.count, 6)
		XCTAssertEqual(statement.wordCount, 0)
	}

	func testAppendSecondBurst()
	{
		let statement = SqlStatement(statement: "sel")
		statement.appendChrsToStatement(nextChars: "ect", withRange: 3..<6)
		XCTAssertEqual(statement.statementText.count, 6)
		XCTAssertEqual(statement.wordCount, 0)
	}

	func testAppendFirstWord()
	{
		let statement = SqlStatement(statement: "select")
		statement.appendChrsToStatement(nextChars: " ", withRange: 6..<7)
		XCTAssertEqual(statement.statementText.count, 7)
		XCTAssertEqual(statement.wordCount, 1)
	}

	func testFirstWordCheck()
	{
		let statement = SqlStatement(statement: "select")
		statement.appendChrsToStatement(nextChars: " ", withRange: 6..<7)
		guard let wordCreated : SqlWord = statement.lastWord
		else
		{
			XCTFail()
			return
		}

		XCTAssertEqual(wordCreated.word, "select")
		XCTAssertTrue(wordCreated.foundInList)
		XCTAssertEqual(wordCreated.wordRange, 0..<6)
	}

	func testAppendCharacterAfterFirstWord()
	{
		let statement = SqlStatement(statement: "select ")
		statement.appendChrsToStatement(nextChars: "*", withRange: 7..<8)
		XCTAssertEqual(statement.statementText.count, 8)
		XCTAssertEqual(statement.wordCount, 1)
		XCTAssertTrue(statement.lastWord!.foundInList, "End word not found in list")
	}

	func testAppendSecondWord()
	{
		let statement = SqlStatement(statement: "select *")
		statement.appendChrsToStatement(nextChars: " ", withRange: 8..<9)
		XCTAssertEqual(statement.statementText.count, 9)
		XCTAssertEqual(statement.wordCount, 2)
		XCTAssertFalse(statement.lastWord!.foundInList, "End word found in list")
	}

	func testAppendBurst()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select ", withRange: 0..<7)
		XCTAssertEqual(statement.statementText.count, 7)
		XCTAssertEqual(statement.wordCount, 1)
		XCTAssertTrue(statement.lastWord!.foundInList, "End word not found in list")
	}

	func testAppendBurstPartial()
	{
		let statement = SqlStatement(statement: "sel")
		statement.appendChrsToStatement(nextChars: "ect ", withRange: 3..<7)
		XCTAssertEqual(statement.statementText.count, 7)
		XCTAssertEqual(statement.wordCount, 1)
		XCTAssertTrue(statement.lastWord!.foundInList, "End word not found in list")
	}

	func testAppendBurstPartialMultiWord()
	{
		let statement = SqlStatement(statement: "sel")
		statement.appendChrsToStatement(nextChars: "ect * from", withRange: 3..<13)
		XCTAssertEqual(statement.statementText.count, 13)
		XCTAssertEqual(statement.wordCount, 2)
		XCTAssertFalse(statement.lastWord!.foundInList, "End word found in list")
	}

	func testFarAppendFirstCharacters()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select * from", withRange: 20..<33)
		XCTAssertEqual(statement.statementText.count, 13)
		XCTAssertEqual(statement.wordCount, 2)
		XCTAssertFalse(statement.lastWord!.foundInList, "End word found in list")
	}

	func testFarAppendWordCheck()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select * from", withRange: 20..<33)
		XCTAssertEqual(statement.lastWord?.word, "*")
		XCTAssertFalse(statement.lastWord!.foundInList)
		XCTAssertEqual(statement.lastWord?.wordRange.lowerBound, 27)
	}

	func testAlmostCompleteStatement()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select * from testTable where rhs = lhs", withRange: 0..<39)
		XCTAssertEqual(statement.statementText.count, 39)
		XCTAssertEqual(statement.wordCount, 7)
		XCTAssertFalse(statement.lastWord!.foundInList, "End word found in list")
	}

	func testCompletingStatement()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select * from testTable where rhs = lhs;", withRange: 0..<40)
		XCTAssertEqual(statement.statementText.count, 40)
		XCTAssertEqual(statement.wordCount, 8)
		XCTAssertFalse(statement.lastWord!.foundInList, "End word found in list")
		XCTAssertTrue(statement.isComplete)
	}

	func testCompleteStatementWordCheck()
	{
		let statement = SqlStatement(statement: "")
		statement.appendChrsToStatement(nextChars: "select * from testTable where rhs = lhs;", withRange: 0..<40)
		XCTAssertEqual(statement.lastWord!.word, "lhs")
		XCTAssertEqual(statement.lastWord!.wordRange, 36..<39)
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
