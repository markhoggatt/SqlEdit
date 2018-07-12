//
//  WordFinderTests.swift
//  SqlEdit
//
//  Created by Mark Hoggatt on 27/07/2017.
//  Copyright © 2017 Code Europa. All rights reserved.
//

import XCTest
@testable import SqlEdit

class WordFinderTests: XCTestCase
{
	var langProc : LanguageProcessor? = nil

    override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

		langProc = LanguageProcessor()
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

		langProc = nil
    }

	func testCanProcessReservedWords()
	{
		guard let lp : LanguageProcessor = langProc
		else
		{
			XCTFail()
			return
		}

		let processedOk : Bool = lp.ProcessReservedWords()
		XCTAssertTrue(processedOk, "Failed to process reserved words.")
	}

	func testCanFindWordsInTrie()
	{
		guard let lp : LanguageProcessor = langProc
			else
		{
			XCTFail()
			return
		}

		let processedOk : Bool = lp.ProcessReservedWords()
		XCTAssertTrue(processedOk, "Failed to process reserved words prior to search.")

		let searchTerms = [String](arrayLiteral: "select", "from", "where", "drop", "insert", "update", "delete")
		for term : String in searchTerms
		{
			let foundOk : Bool = lp.IsWordFound(refWord: term)
			XCTAssertTrue(foundOk)
		}

		let wrongTerms = [String](arrayLiteral: "solect", "fron", "whire", "drip", "insest", "ipdate", "delate")
		for term : String in wrongTerms
		{
			let foundOk : Bool = lp.IsWordFound(refWord: term)
			XCTAssertFalse(foundOk)
		}
	}

    func testPerformanceWordLookup()
	{
		guard let lp : LanguageProcessor = langProc
			else
		{
			XCTFail()
			return
		}

		let processedOk : Bool = lp.ProcessReservedWords()
		XCTAssertTrue(processedOk, "Failed to process reserved words prior to performance test.")

		let searchTerms = [String](arrayLiteral: "select", "from", "where", "drop", "insert", "update", "delete")

        self.measure
		{
			for term : String in searchTerms
			{
				let foundOk : Bool = lp.IsWordFound(refWord: term)
				XCTAssertTrue(foundOk)
			}
        }
    }

	func testPartialMatch()
	{
		guard let lp : LanguageProcessor = langProc
			else
		{
			XCTFail()
			return
		}

		let processedOk : Bool = lp.ProcessReservedWords()
		XCTAssertTrue(processedOk, "Failed to process reserved words prior to partial match test.")

		let isPartialMatch : Bool = lp.IsStringFound(refString: "selec")
		XCTAssertTrue(isPartialMatch)
	}

	func testPrefixMatch()
	{
		guard let lp : LanguageProcessor = langProc
			else
		{
			XCTFail()
			return
		}

		let processedOk : Bool = lp.ProcessReservedWords()
		XCTAssertTrue(processedOk, "Failed to process reserved words prior to last word in trie test.")

		let matched : [String] = lp.WordsMatchingPrefix(prefix: "comm")
		XCTAssertNotNil(matched)
		XCTAssertGreaterThan(matched.count, 0)
	}
}
